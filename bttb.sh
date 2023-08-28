#!/bin/bash
## -----------------------------------------------------------------------
## Intent: This script will tag and branch repositories for release.
##   o Actions are per-repository: two are branch-tag else tag-branch
##   o branch-tag repositories:
##     voltha-helm-charts
##     voltha-system-tests
##   o tag-branch everything else
## -----------------------------------------------------------------------

pgm_root="$(realpath "${BASH_SOURCE[0]%/*}")"
cd "$pgm_root"

source "${pgm_root}/bttb/detect.sh"
source "${pgm_root}/bttb/get_tag.sh"
source "${pgm_root}/bttb/branch.sh"
source "${pgm_root}/bttb/gitreview.sh"
source "${pgm_root}/bttb/tag.sh"

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
function error()
{
    echo "** ${FUNCNAME[1]} ERROR: $*"
    exit 1
}

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
function do_continue()
{
    echo
    echo -en "$*\nContinue ?"

    local ans
    read ans
    return
}

##----------------##
##---]  MAIN  [---##
##----------------##
declare -a actions=()
declare -a repos=()
while [ $# -gt 0 ]; do
    arg="$1"; shift
    case "$arg" in
	--action)
	    arg="$1"; shift
	    actions+=("$arg")
	    ;;
	--repo)
	    arg="$1"; shift
	    repos+=("$arg")
	    ;;
    esac
done

[[ ${#repos[@]} -eq 0 ]] \
    && error '--repo [r] is a required argument'

ver='2.12'
release_name="${ver}-beta"
branch=''
tag=''

for repo in "${repos[@]}";
do
    echo
    echo "REPO: $repo"

    detect_branch_tag "$repo" "$ver" branch tag
    
    declare -p tag
    declare -p branch
    declare -p ver

    [[ "${#actions[@]}" -eq 0 ]] \
	&& detect_actions "$repo" actions

    declare -p actions
    
for action in "${actions[@]}";
do
    case "$action" in
	checkout)
	    /bin/rm -fr "$repo"
	    echo "** clone $repo"
	    make "$repo" >/dev/null
	    continue
	    ;;
    esac

    cat <<EOF

** -----------------------------------------------------------------------
** REPO: $repo, ACTION: $action
** -----------------------------------------------------------------------
EOF
    pushd "$repo" >/dev/null
    case "$action" in

	info) echo "INFO" ;;
	gitreview) update_gitreview ;;

	TB-create-tag)

	    git fetch

	    tag=''
	    get_tag "$ver" tag

	    msg="$release_name release: branch $branch created from tag $tag"

	    if is_tag "$tag_name"; then
		echo "[SKIP] tag $tag_name exists"

		## Not yet able to update message when remote tag exists.
		# git tag <tag name> <tag name>^{} -f -m "<new message>"
		# git tag "$tag" "$tag^{}" -f -m "$msg"
	    else
		set -x
		git tag -a "$tag" -m "$msg"
		set +x

		set -x
		git tag | grep "$ver"
		git push origin "$tag"
		set +x
		echo
		echo "TAG INFO:"
		echo "======================================================================="
		git for-each-ref "refs/tags/$tag" --format='%(contents)'	
	    fi

	    do_continue "TB-create-tag"
	    ;;

	# git checkout -b voltha-2.12 tags/2.12.0
	TB-create-branch)
	    set -x
	    git fetch
	    git checkout -b "$branch" "tags/$tag"
	    git push -u origin "$branch" "tags/$tag"
	    set +x
	    do_continue "TB-create-branch"
	    ;;

#** -----------------------------------------------------------------------
#** REPO: pod-configs, ACTION: TB-create-branch
#** -----------------------------------------------------------------------
#Switched to a new branch 'voltha-2.12'
#To ssh://gerrit.opencord.org:29418/pod-configs.git
# ! [rejected]        2.12.0 -> 2.12.0 (already exists)
#Branch 'voltha-2.12' set up to track remote branch 'voltha-2.12' from 'origin'.
#error: failed to push some refs to 'ssh://gerrit.opencord.org:29418/pod-configs.git'
#hint: Updates were rejected because the tag already exists in the remote.

	
	BT-create_branch)
	    git fetch
	    git checkout -b "$branch"
	    git push -u origin "$branch"
	    show_branch
	    ;;

	BT-create_tag)
	    git fetch
	    git checkout -b "$branch"

	    msg="$release_name release: tag $tag created from branch $branch"
	    git tag -a "$tag" -m "$msg"
	    # git tag | grep "$ver"
	    git push origin "$tag"
	    show_tag

	    show_annotation
	    ;;
	
	graph)
	    cat <<EOF

** -----------------------------------------------------------------------
** git log --graph --decorate --oneline | grep "$ver"
** -----------------------------------------------------------------------
EOF
	    git log --graph --decorate --oneline | grep "$ver"
	    ;;
	
	rebase)
	    cat <<EOF
** -----------------------------------------------------------------------
** ACTION: rebase
** -----------------------------------------------------------------------
EOF
	    git pull --ff-only origin "$branch"
	    git rebase -i "$branch"
	    git diff --name-only "$branch" 2>&1 | less


	    # https://stackoverflow.com/questions/12469855/git-rebasing-to-a-particular-tag
	    # rebase to a tag
	    # git rebase --onto v1.5 v1.0 dev-branch
	    ;;

	review)
	    echo "NYI"
	    # git review --reviewers
	    ;;

	docs)
	    "${pgm_root}/bttb/docs.sh" --repo "$repo" 
	    ;;


	## -----------------------------------------------------------------------
	## Interactive action -- edit tag annotation
	## -----------------------------------------------------------------------
	BT-edit-annotation)
	    git tag "$tag" "${tag}^{}" -f -m "$tag release tag created from branch $branch"
	    ;;

	TB-edit-annotation)
	    git tag "$tag" "${tag}^{}" -f -m "$branch release branch created from tag $tag"
	    ;;
	
	show-annotation)
	    # Show annotations
	    git for-each-ref refs/tags/"$tag" --format='%(contents)'
	    ;;
	
    esac
    popd >/dev/null
    
done # action
done # repos

# [EOF]
