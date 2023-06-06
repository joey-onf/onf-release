#!/usr/bin/env python
"""Probe for network resources."""

##-------------------##
##---]  GLOBALS  [---##
##-------------------##

##-------------------##
##---]  IMPORTS  [---##
##-------------------##
import sys
import pprint

from pathlib           import Path

from mkrelease.main    import utils           as main_utils
from mkrelease.main    import argparse        as main_getopt



# open repo on disk
# my_repo = git.Repo('existing_repo')


## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
def clone(name:str):
    '''
.. seealso: https://gitpython.readthedocs.io/en/stable/tutorial.html
'''

    # https://stackoverflow.com/questions/28291909/gitpython-and-ssh-keys
    # argv  = main_getopt.get_argv()
    # from git import Repo
    # from git import Git
    import git

    import pdb
    pdb.set_trace()
    
    repo = 'ssh://joey@opennetworking.org@gerrit.opencord.org:29418/%s.git' % name
    git.Repo.clone_from(repo, '.')
    pdb.set_trace()
    xy = 1
    
#    git.Repo.clone_from(repo, name)
#    git_ssh_identity_file = os.path.expanduser('~/.ssh/id_rsa')
#    git_ssh_cmd = 'ssh -i %s' % git_ssh_identity_file

    # https://www.devdungeon.com/content/working-git-repositories-python
#    with Git().custom_environment(GIT_SSH_COMMAND=git_ssh_cmd):
#        Repo.clone_from(repo, name) # branch='my-branch')

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
def main(argv_raw):
    '''.'''

    main_getopt.getopts(argv_raw)    
    argv  = main_getopt.get_argv()
    # morph short argument into semver -- maybe a cast function

    with main_utils.pushd(systemp=True):
        repo_name = 'voltha_docs'
        clone(repo_name)

#        my_repo = git.Repo(repo_name)
#        # List all branches
#        for branch in repo.branches:
#            print(branch)        

##----------------##
##---]  MAIN  [---##
##----------------##
if __name__ == "__main__":
    main(sys.argv[1:]) # NOSONAR

# [EOF]
