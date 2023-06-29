#!/bin/bash
## -----------------------------------------------------------------------
## Intent: Generate a script for gathering onos version information
##   o gather and generate a commented list of changesets.
##   o iterate, show {version, blame, diff}
## -----------------------------------------------------------------------

##-------------------##
##---]  GLOBALS  [---##
##-------------------##
set -euo pipefail
declare -g -i debug=1

declare -g start_pwd  # repo_dir
start_pwd=$(realpath --canonicalize-existing .)

##-------------------##
##---]  INCLUDE  [---##
##-------------------##
source ~/.sandbox/common/common_args.sh

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function error()
{
    echo "** ${BASH_SOURCE[0]}::${FUNCNAME[1]} ERROR: $*"
    exit 1
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function func_echo()
{
    echo "** ${BASH_SOURCE[0]}::${FUNCNAME[1]}: $*"
    return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function init()
{
    declare -g work
    common_tempdir_mkdir work
    readonly work
#    sigtrap_preserve

    export TEMPDIR="$work"

    declare -g repo_name
    local repo_path
    repo_path="$(git rev-parse --show-toplevel)"
    repo_name="${repo_path##*/}"

    [[ -v debug ]] && func_echo "$(declare -p work)"
    [[ -v debug ]] && func_echo "$(declare -p repo_path)"
    [[ -v debug ]] && func_echo "$(declare -p repo_name)"

    return
}

## -----------------------------------------------------------------------
## Intent: Gather changesets
## -----------------------------------------------------------------------
function gather_changesets_0()
{
    declare -n ref=$1; shift
    readarray -t __tmp < <(git log pom.xml \
			       | grep '^commit' \
			       | cut -d' ' -f2 \
			  )

    ref=("${__tmp[@]}")
    return
}

## -----------------------------------------------------------------------
## Intent: Gather changesets
## -----------------------------------------------------------------------
function gather_changesets()
{
    declare -n ref=$1; shift

    readarray -t __tmp_cs < <(git log pom.xml \
	| grep '^commit' \
	| cut -d' ' -f2 \
	| sed -e "s@^@# cs+=('@" | sed -e "s@\$@')@")
    
    ref=("${__tmp_cs[@]}")
    return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function shell_header()
{
    cat <<EOH
#!/bin/bash
## -----------------------------------------------------------------------
## Intent: Gather repository data for onos projects
## -----------------------------------------------------------------------

##-------------------##
##---]  GLOBALS  [---##
##-------------------##
set -euo pipefail
EOH

    return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function shell_changesets()
{
    cat <<EOH

## -----------------------------------------------------------------------
## Changesets to interrogate
## -----------------------------------------------------------------------

declare -a cs=()
EOH

    printf "# cs+=('%s')\n" "${changesets[@]}" 

    return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function shell_do_diff()
{
    cat <<EOH

## -----------------------------------------------------------------------
## Intent: Display delta between two revisions
## -----------------------------------------------------------------------
EOH

cat <<CMD_DIFF
function do_diff()
{
   local cs1="\$1"; shift
   local cs2="\$1"; shift
   local range="\${cs1}..\${cs2}"

   git diff "\$range" pom.xml
   return
}
CMD_DIFF
    
    return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function shell_do_blame()
{
    cat <<EOH

## -----------------------------------------------------------------------
## Intent: Display deltas between revisions
## -----------------------------------------------------------------------
EOH
    
cat <<CMD_BLAME
function do_blame()
{
   declare -n ref=\$1; shift

   local val
   for val in "\${ref[@]}";
   do
       git checkout -b "\$val"
       echo
       echo "CHANGESET: \$val"
       echo "-----------------------------------------------------------------------"
       # git blame 'pom.xml'
       git blame "\$val"
   done
   return
}
CMD_BLAME
return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function shell_do_main()
{
        cat <<FUNC
## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
function check_cs()
{
    if [[ \${#cs[@]} -eq 0 ]]; then
       echo "Uncommment a few changesets in \${BASH_SOURCE[0]}"
       exit 1
    fi

    return
}
FUNC


    
    cat <<EOH

## ----------------##
## ---]  MAIN  [---##
## ----------------##
EOH

    cat <<CMD_MAIN
declare -a actions=()
# actions+=('blame')
# actions+=('diff')
actions+=('api-ver')
actions+=('app-ver')
actions+=('pkg-ver')
# actions+=('versions')

if [[ \${#actions[@]} -eq 0 ]]; then
   echo "Select actions to perform in \${BASH_SOURCE[0]}"
   exit 1
fi

declare -p actions
action=''
for action in "\${actions[@]}";
do
    case "\$action" in

      blame)
          check_cs
          do_blame cs
	  ;;

      diff)
          check_cs
          do_diff "\${cs[1]}" "\${cs[0]}"
	  ;;

      api-ver)
	  echo
	  echo "** API VERSIONS"
          readarray -t fyls < <(find . -name 'pom.xml' -print)
	  grep 'api.version' "\${fyls[@]}" \\
	      | sed -e 's/:[[:blank:]]*/\t\t: /' \\
	      | sort -u
          ;;

      app-ver)
	  echo
	  echo "** APP VERSIONS"
          readarray -t fyls < <(find . -name 'pom.xml' -print)
	  grep 'app.version' "\${fyls[@]}" \\
	      | sed -e 's/:[[:blank:]]*/\t\t: /' \\
	      | sort -u
          ;;

      pkg-ver)
          repo_name="$repo_name"
	  echo
	  echo "PKG: \$repo_name"
          readarray -t fyls < <(find . -name 'pom.xml' -print)
	  grep "\$repo_name" "\${fyls[@]}" \
	      | grep 'version' \\
	      | sed -e 's/:[[:blank:]]*/\t\t: /' \\
	      | sort -u
          ;;

      versions)
	  echo
	  echo "Version strings"
          readarray -t fyls < <(find . -name 'pom.xml' -print)
	  grep '[[:digit:]]\.[[:digit:]]' "\${fyls[@]}"
          ;;
      *)
          echo "ERROR: Invalid action [\$action]"
	  exit 1
	  ;;
    esac
done
# [[ -v arg_diff ]] && do_diff "\${cs[1]}" "\${cs[0]}"
# [[ -v arg_blame ]] && do_blame cs
CMD_MAIN

return
}

## -----------------------------------------------------------------------
## Intent:
## -----------------------------------------------------------------------
function triage()
{
    local dir="$1"; shift

    ## Extract hierarchy
    local stem="${dir%/*}"
    local subdir="${stem##*/}"

    case "$subdir" in
	.) subdir='pgm' ;; # ./pom.xml
    esac

    func_echo "SUBDIR: $subdir (dir=$dir)"
    ## Guard to prevent typo over-writing
    [[ -d "$work/subdir" ]] \
	&& error "path=$dir, subdir=[$subdir] already exists"

    mkdir -p "$subdir"
    pushd "$subdir" >/dev/null

    pushd "$start_pwd" >/dev/null
    declare -a changesets=()
    gather_changesets_0 changesets
    popd               >/dev/null # start_pwd

    printf '%s\n' "# ${changesets[@]}" > changesets

    (
	shell_header
	shell_changesets changesets
	shell_do_blame
	shell_do_diff
	shell_do_main
	echo
	echo "# [EOF]"
    ) > compare.sh
    chmod 755 compare.sh
    
    popd            >/dev/null # subdir

    return
}

##----------------##
##---]  MAIN  [---##
##----------------##
[[ ! -e pom.xml ]] && error "pom.xml does not exist"

init

[[ $# -gt 0 ]]  && { declare -a todos=("$*"); }
[[ ! -v todos ]] && readarray -t todos < <(find . -name 'pom.xml' -print)

mkdir -vp "$work"
pushd "$work"
declare -p todos > todos

declare todo=''
for todo in "${todos[@]}";
do
    triage "$todo"
done # todos

    cat <<EOH


## -----------------------------------------------------------------------
## Generated files
## -----------------------------------------------------------------------
$(find . -ls)
EOH
    
popd >/dev/null # work

mkdir -p generated
rsync -r --checksum "$work/." "generated/."


# [EOF]
