#!/bin/bash

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
function update_gitreview()
{
    local br="$1"; shift

    banner "Create"

    grep -v 'defaultbranch' .gitreview > .gitreview.tmp
    echo "defaultbranch=${br}" >> .gitreview.tmp
    mv -f .gitreview.tmp .gitreview
    git add .gitreview

    git diff .gitreview
    git status

    return
}

# [EOF]
