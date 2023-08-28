#!/bin/bash

## -----------------------------------------------------------------------
## Intent: Detect type of repository tag:
##   o golang   prefix='v'
##   o else     prefix=NONE
## -----------------------------------------------------------------------
function get_tag()
{
    local __ver="$1"; shift
    local -n ref_tag=$1; shift

    declare -p __ver
    readarray -t tags < <(git tag --list | grep -E '^v')

    ## Hack alert: some repos have bad v2.12.0 tags, removal difficult
    readarray -t remotes < <(git remote -v show | head -n 1 | cut -d'/' -f3)
    local remote
    for remote in "${remotes[@]}";
    do
	case "$line" in
	    pod-configs) ;;
	    openolt.git) tags=()     ;; # non-vee
	    voltha-onos.git) tags=() ;; # non-vee
	esac
    done

    if false; then
       :
    elif [[ -v have_vee ]]; then
	error "NYI"
	:
	
    elif [[ ${#tags[@]} -eq 0 ]]; then
	ref_tag="${__ver}.0"
    # repo:voltha-onos has bogus tags
    elif [[ ${#tags[@]} -lt 5 ]]; then
	ref_tag="${__ver}.0"
    else
	ref_tag="v${__ver}.0"
    fi
 
    return
}

: # $?=0

# [EOF]
