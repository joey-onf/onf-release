# -*- python -*-
'''This module handles command line argument parsing.

..todo: https://docs.python.org/3/library/argparse.html##
'''

##-------------------##
##---]  GLOBALS  [---##
##-------------------##
ARGV      = None
namespace = None

##-------------------##
##---]  IMPORTS  [---##
##-------------------##
import argparse
import pprint

from mkrelease.main        import utils              as main_utils
from mkrelease.main        import argparse_actions   as ar_ac

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
def get_argv():
    """Retrieve parsed command line switches.

    :return: Parsed command line argument storage
    :rtype : dict
    """

    global ARGV
    global namespace

    if ARGV is None:
        # Normalize argspace/namespace into a getopt/dictionary
        # Program wide syntax edits needed: args['foo'] => args.foo
        arg_dict = {}
        for arg in vars(namespace):
            arg_dict[arg] = getattr(namespace, arg)
        ARGV = arg_dict

    return ARGV

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
def getopts(argv, debug=None) -> None:
    """Parse command line args, check options and pack into a hashmap

    :param argv: values passed on the command line
    :param debug: optional flag to enable debug mode

    :return: Digested command line arguments
    :rtype : dict

    :raises  ValueError

    ..note: A dictionary is returned for backward compatibility.
    ..note: arg syntax should change from foo['debug'] to foo.debug
    ..note: allowing raw library return type(namespace) to be used.

    ..todo: support --dry-run, deploy actions w/o final import request.

    ..todo: Strange decorate a switch with required=True.  Pass switch through
    ..todo: --response fails even though value(s) are in parsed args namespace.

    .. versionadded:: 1.3
    """

    global namespace

    iam = main_utils.iam()

    if debug is None:
        debug = False

    parser = argparse.ArgumentParser\
             (
                 description = 'Create a versioned release for a project',
             )

    ## -----------------------------------------------------------------------
    ## -----------------------------------------------------------------------
    parser.add_argument('--project',
                        action   = 'store',
                        required = True,
                        type    = ar_ac.valid_onf_project,
                        help    = 'Package name to release',
                    )

    ## -----------------------------------------------------------------------
    ## -----------------------------------------------------------------------
    parser.add_argument('--release-version',
                        action   = 'store',
                        required = True,
                        type    = ar_ac.valid_semantic_version,
                        help    = 'Package version to release.',
                    )

    ## -----------------------------------------------------------------------
    ## [MODES]
    ## -----------------------------------------------------------------------
    parser.add_argument('--debug',
                        action  = 'store_true',
                        default = False,
                        help    = 'Enable script debug mode',
                    )

    parser.add_argument('--dry-run',
                        action  = 'store_true',
                        default = False,
                        help    = 'Perform detection w/o create or modify.',
                    )

    parser.add_argument('--trace',
                        action  = 'store_true',
                        default = False,
                        help    = 'Enable full time tracing for probes',
                    )

    parser.add_argument('--verbose',
                        action  = 'store_true',
                        default = False,
                        help    = 'Enable script verbose mode',
                    )
    
    parser.add_argument('--version', action='version', version='%(prog)s 1.0')


    namespace = parser.parse_args()
    return

# [EOF]
