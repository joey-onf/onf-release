#!/bin/bash
## -----------------------------------------------------------------------
## Intent: Bulk license checking
## -----------------------------------------------------------------------

set -euo pipefail

case "$USER" in
    jo*) source ~/.sandbox/common/common.sh '--common-args-begin--' ;;
esac

##-------------------##
##---]  GLOBALS  [---##
##-------------------##
declare -g work=''

## -----------------------------------------------------------------------
## Intent: Display an error message then exit
## -----------------------------------------------------------------------
function error()
{
    echo "${BASH_SOURCE[0]} ERROR: $@"
    exit 1
}

## -----------------------------------------------------------------------
## Intent: The reuse tool does not support exclusions.  As a workaround
##   create a new sandbox and exclude content while copying.
## -----------------------------------------------------------------------
function create_sandbox()
{
    local dst="$1"; shift
    local src="$1"; shift

    rargs+=('--checksum')
    rargs+=('--recursive')
    # rargs+=('--verbose')
    
    rargs+=('--exclude-from=copy-filter.rsync')
    rsync -r "${rargs[@]}" "$src/." "$dst/."

    return
}

##----------------##
##---]  MAIN  [---##
##----------------##
common_tempdir_mkdir work
create_sandbox "$work" "../sandbox"


pushd "$work" >/dev/null || { error "pushd failed: $work"; }

if false; then
    readarray -t dirs < <(find . -name 'LICENSE' -print)
else
    declare -a dirs=('.')
fi

for dir in "${dirs[@]}";
do
    
    if false; then
        path="${dir%/*}"
        echo
        echo "CHECKING: $path"
    else
        path="$dir"
    fi
    reuse --root "$path" lint
#    reuse --root . lint
done
popd          >/dev/null

# [EOF]
