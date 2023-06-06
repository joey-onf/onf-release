#!/bin/bash
## --------------------------------------------------------------------
## --------------------------------------------------------------------

# TOP="$(realpath "${0%/*}")"
TOP="$(realpath '.')"

## --------------------------------------------------------------------
## --------------------------------------------------------------------
function gather_guide()
{
    local logdir="$1"; shift
    
    (
	set -x
	grep -r '://guide.opencord.org/logos' .
	set +x
    ) >> "$logdir/logos.log"
    return
}

## --------------------------------------------------------------------
## --------------------------------------------------------------------
function version_bbsim()
{
    # Chart.yaml :: appVersion: 1.12.10 correlates to git tag
    # https://gerrit.opencord.org/plugins/gitiles/voltha-helm-charts/+/refs/heads/master/bbsim/Chart.yaml#17
    return
}

## --------------------------------------------------------------------
## --------------------------------------------------------------------
function version_voltha_openolt_adapter()
{
    cat<<EOF
name: "voltha-adapter-openolt"
version: "2.11.3"
appVersion: "4.2.6"
EOF
    return
}

## --------------------------------------------------------------------
## --------------------------------------------------------------------
function version_check()
{
    cat<<EOF
REPOS:
   o bbsim
   o voltha-adapter-openolt
 o obtain appVersion string from chart.yaml
 o verify repo: git tag | grep "$appVersion"
EOF
EOF
}

## --------------------------------------------------------------------
## --------------------------------------------------------------------
function bulk_checkout()
{
    local logdir="$1"; shift
    
    readarray -t repos < <(\
			   grep '://' "${TOP}/repos"  \
			   | awk -F\# '{print $1}'    \
			   | grep '://'               \
			  )

    for git_url in "${repos[@]}";
    do
	repo="${url##*/}"
	[[ -d "$repo" ]] && continue

	echo
	git clone "${git_url}" >/dev/null

	pushd "${repo}" >/dev/null
	mkdir -p "$logdir/$name"
	git branch > "$logdir/$name/branches"
	git tag    > "$logdir/$name/tag"
	popd            >/dev/null
    done

    return
}

##----------------##
##---]  MAIN  [---##
##----------------##
proj=voltha
ver=9999999
semver="${proj}-${ver}"

logdir="${TOP}/logs"
mkdir -p "$logdir"
mkdir -p sandbox

# mktemp
mkdir -p sandbox
pushd sandbox >/dev/null
  mkdir -p branches
  bulk_checkout  "$logdir"
  gather_guide   "$logdir"
popd          >/dev/null

# [EOF]
