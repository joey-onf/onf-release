# -*- python -*-

##-------------------##
##---]  GLOBALS  [---##
##-------------------##

##-------------------##
##---]  IMPORTS  [---##
##-------------------##
import argparse
import semantic_version
    # v = semantic_version.Version('0.1.1')
    # v.major
    # v.minor
import validators

from pathlib           import Path
from validators        import ValidationFailure

# -----------------------------------------------------------------------
# -----------------------------------------------------------------------
def valid_onf_project(arg: str) -> str:
    '''Verify argument is an onf project name.'''

    arg = arg.strip()
    valid_projects = ['aether', 'onos', 'voltha']

    if arg not in valid_projects:
        msg = 'Detected invalid project name %s' % (arg)
        raise argparse.ArgumentTypeError(msg)

    return arg

# -----------------------------------------------------------------------
# -----------------------------------------------------------------------
def valid_semantic_version(arg: str) -> str:
    '''Validate version string argument.'''

    arg = arg.strip()
    dots = [letter for letter in arg if letter == '.']
    tmp_arg = "%s.0" % arg if (len(dots) == 1) else arg
    is_semver = semantic_version.validate(tmp_arg)

    if not is_semver:
        msg = 'Detected invalid semantic version string %s' % (arg)
        raise argparse.ArgumentTypeError(msg)

    return arg

# [EOF]
