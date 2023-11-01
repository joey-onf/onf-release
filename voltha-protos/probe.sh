#!/bin/bash
## -----------------------------------------------------------------------
## Intent: Release validation, screen go.mod files for an invalid
##   repo:voltha-proto version string.
## -----------------------------------------------------------------------

declare -a -g errors=()

## -----------------------------------------------------------------------
## Intent: Display an error message then exit.
## -----------------------------------------------------------------------
function error()
{
    echo "${BASH_SOURCE[1]} ERROR: $*"
    exit 1
}

## -----------------------------------------------------------------------
## Intent: Join a list of elements using delimiter
## -----------------------------------------------------------------------
## Given:
##   $1   Delimiter to join list on
##   $2+  A list of items to join
## -----------------------------------------------------------------------
## Usage:
##   local val=$(join_by ':' "${fields[@]}")
## -----------------------------------------------------------------------
function join_by()
{
    local d=${1-} f=${2-}; if shift 2; then printf %s "$f" "${@/#/$d}"; fi;
}

## -----------------------------------------------------------------------
## Intent: Retrieve VERSION file string from voltha-protos::VERSION
## -----------------------------------------------------------------------
## Given:
##   path    VERSION file path to retrieve a version string from.
## Return:
##   ref     Return version to caller through this indirect var reference
## -----------------------------------------------------------------------
function getVersionString()
{
    local -n ref=$1; shift
    local path="$1"; shift

    # vX.Y.Z(-tans|-fans)
    readarray -t versions < <(grep -E \
        -e '^\b([[:digit:]]+(\.[[:digit:]]+){2}-?[[:alnum:]]*)\b' \
        "$path"\
        )
                              
    if [[ ${#versions[@]} -eq 0 ]]; then
        cat <<EOM
   VERSION file: $path
Expected format: v#.#.#[-dev#]
Found: $(cat $path)
EOM
        error "Detected invalid version file string"

    elif [[ ${#versions[@]} -ne 1 ]]; then
        cat <<EOM
   VERSION file: $path
Found: $(cat $path)
EOM
        error "Detected multiple version strings"
    fi

    ref="v${versions[0]}"
    return
}

## -----------------------------------------------------------------------
## Intent: Gather go.mod files and detect stale voltha-protos version.
## -----------------------------------------------------------------------
function detectVersion()
{
    local exp="$1"; shift
    # local -i debug=1
    
    readarray -t matched < <(find . -name 'go.mod' -print0 \
                                 | xargs -0 grep '/voltha-protos/' \
                                 | grep -v --fixed-strings -e "$exp" \
                            )

    local line
    for line in "${matched[@]}";
    do
        [[ -v debug ]] && echo "LINE: $line"
        local found=$(echo "$line" | awk -F: '{print $1}')

        # Split('/', path)
        readarray -d'/' -t fields < <(printf '%s' "$found")
        local repo="${fields[1]}"
        local gomod=$(join_by '/' "${fields[@]:2}")

        local bad=$(echo "$line" | awk '{print $3}')
        errors+=("Detected invalid voltha-protos VERSION (got=$bad != exp=$exp)")
        # Why are these not indented properly ?
        errors+=("  Repo: $repo")
        errors+=("  Path: $gomod")
    done

    return
}

## -----------------------------------------------------------------------
## Intent: Display an error report when failures are detected
## -----------------------------------------------------------------------
function report()
{
    [[ "${#errors[@]}" -eq 0 ]] && return

    cat <<EOE
    
** -----------------------------------------------------------------------
** Intent: Validate voltha-protos version across repositories.
**    IAM: ${BASH_SOURCE[0]##*/}
**   Date: $(date)
**  Error: Detected invalid voltha-proto versions
** -----------------------------------------------------------------------
EOE

    echo -e $(join_by '\n' "${errors[@]}")
    return
}

##----------------##
##---]  MAIN  [---##
##----------------##
[[ $# -eq 0 ]] && { echo "ERROR: sandbox path is required"; exit 1; }
sbx="$1"; shift

override='overrides/voltha-protos/VERSION'
versionFile="$sbx/voltha-protos/VERSION"
if [ -f "$override" ]; then
    versionFile="$override"
fi
readonly versionFile

declare ver
getVersionString ver "$versionFile"

pushd "$sbx" >/dev/null
detectVersion "$ver"

popd >/dev/null

report

[[ ${#errors[@]} -gt 0 ]] && error "Problems detected, exiting with status"

# [EOF]
