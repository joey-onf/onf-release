#!/bin/bash
## -----------------------------------------------------------------------
## -----------------------------------------------------------------------

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
function detect_branch_tag()
{
    local __repo="$1"; shift
    local __vers="$1"; shift
    local -n refB=$1; shift
    local -n refT=$1; shift

    [[ ! -v "$__repo" ]] && make "$__repo" >/dev/null

    pushd "$__repo"
    refB="voltha-${__vers}"
    get_tag "${__vers}" refT
    popd

    return
}

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
function detect_actions()
{
    local __repo="$1"; shift
    local -n ref=$1; shift

    ref=()
    ref+=('checkout')	
    ref+=('docs')
    
    case "$__repo" in
	# pod-configs)
	#   - no version file
	#   - no tags (ver: 2.11 & 2.12 created earlier)
	voltha-helm-charts|voltha-system-tests)
	    ref+=('BT-create_branch')	
	    ref+=('BT-create_tag')

	    # ref+=('info')
	    # ref+=('rebase')
	    # ref+=('BT-edit-annotation')

	    ;;

	*)
	    ref+=('TB-create-tag')
	    ref+=('TB-create-branch')

	    # ref+=('rebase')
	    # ref+=('review')
	    # ref+=('TB-edit-annotation')
	    ;;
    esac

    ref+=('gitreview')
    
    ref+=('graph') 
    ref+=('show_branch')
    ref+=('show_tag')
    ref+=('show_annotation')
    
    return
}

# [EOF]
