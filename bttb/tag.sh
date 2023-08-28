#!/bin/bash

## -----------------------------------------------------------------------
## Intent: Debug function, display repo tags
## -----------------------------------------------------------------------
function show_tag()
{
    local __ver="$1"; shift

    cat <<EOS

** -----------------------------------------------------------------------
** ${FUNCNAME[0]}
** -----------------------------------------------------------------------
EOS
    git tag --list 2>&1 | grep "$__ver"
    return
}

## -----------------------------------------------------------------------
## Intent: Copied from release.sh, may not be needed if tags are
##    simple names w/o tag/ prefix.
## -----------------------------------------------------------------------
function getNames()
{
    local -n br=$1; shift
    local -n nm=$1; shift

    nm=()
    local tmp
    for tmp in "${br[@]}";
    do
	nm+=("${tmp##*/}")
    done
    return
}

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
function is_tag()
{
    local arg="$1"; shift

    readarray -t tags < <(git tag --list)

    local -a names=()
    getNames tags names
    # declare -p names

    [[ " ${names[@]} " =~ " $arg " ]] && { true; } || { false; }
    return
}


: # $?=0

# [EOF]
