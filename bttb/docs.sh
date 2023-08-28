#!/bin/bash

pushd ~/projects/sandbox/voltha-docs

##----------------##
##---]  MAIN  [---##
##----------------##
declare -a repos=()

while [ $# -gt 0 ]; do
    arg="$1"; shift
    case "$arg" in
	--repo)
	    arg="$1"; shift
	    repos+=("$arg")
	    ;;
    esac
done

[[ ${#repos[@]} -eq 0 ]] && { echo "--repo is required"; exit 1; }

# repos+=('voltha-go')
# repos+=('voltha-lib-go')
# repos+=('voltha-protos')

declare -a edit=()

base='howto/release/repositories'
for repo in "${repos[@]}";
do
    if ! grep "$repo/index" "$base/index.rst"; then
	echo "   $repo/index" >> "$base/index.rst"
    fi

    repo_dir="$base/$repo"
    if [ ! -d "$repo_dir" ]; then
	mkdir -p "$repo_dir"
	rsync -rv --checksum "$base/voltha-lib-go/." "$repo_dir/."
    fi

    edit+=("$repo_dir")
done

emacs "$repo_dir" &

popd

# [EOF]
