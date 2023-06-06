# -*- python -*-
## -----------------------------------------------------------------------
## Intent: This module contains general helper methods
## -----------------------------------------------------------------------

##-------------------##
##---]  IMPORTS  [---##
##-------------------##
import sys
import os
import pprint
import contextlib

from pathlib           import Path

import tempfile
import shutil             # rmtree
# from shutil             import rmtree

## ---------------------------------------------------------------------------
## ---------------------------------------------------------------------------
def iam(frame=None):
    """Return name of a called method."""

    if frame is None:
        frame = 1

    func_name = sys._getframe(frame).f_code.co_name # pylint: disable=protected-access
    iam       = "%s::%s" % (__name__, func_name)
    return iam

## ---------------------------------------------------------------------------
## ---------------------------------------------------------------------------
def banner(label, *args, pre=None, post=None) -> None:
    """Format output with delimiters for visibility.

    :param pre: Display leading whitespace.
    :type  pre: bool

    :param post: Display leading whitespace.
    :type  post: bool
    """

    if pre:
        print('')

    hyphens = '-' * 71
    print(" ** %s" % hyphens)
    print(" ** %s" % label)

    for arg in args:
        if isinstance(arg, dict):
            pprint.pprint(arg)
        elif isinstance(arg, list):
            todo = arg
            # todo = list_utils.flatten(arg)
            for line in todo:
                print(" ** %s" % line)
        else:
            print(" ** %s" % arg)

    print(" ** %s" % hyphens)

    if post:
        print('')

## -----------------------------------------------------------------------
## Intent: Display a message then exit with non-zero status.
##   This method cannot be intercepted by try/except
## -----------------------------------------------------------------------
def error(msg, exit_with=None, fatal=None):
    """Display a message then exit with non-zero status.

    :param msg: Error mesage to display.
    :type  msg: string

    :param exit_with: Shell exit status.
    :type  exit_with: int, optional (default=2)

    :param fatal: When true raise an exception.
    :type  fatal: bool (default=False)

    """

    if exit_with is None:
        exit_with = 2

    if fatal is None:
        fatal = false

    if msg:
        if fatal:
            raise Exception("ERROR: %s" % msg)
        else:
            print("")
            print("ERROR: %s" % msg)

    sys.exit(exit_with)

## -----------------------------------------------------------------------
## Intent: Emulate pushd/popd/chdir directory stack
## Usage:
##    with utils.pushd('/var/tmp'):
##        print(" ** getcwd[1] %s" % os.getcwd())
## -----------------------------------------------------------------------
@contextlib.contextmanager
def pushd(new_dir=None, debug=None, tempdir=None, systemp=None):
    """Emulate pushd/popd/chdir directory stack.

    :param debug: Enable debug mode
    :type  debug: bool

    :param new_dir: Chdir to this named directory
    :type  new_dir: str, conditional use tempdir if none

    :return: yield back to caller

    Usage:
    with main_utils.pushd('/home'):
        print(" ** cd %s" % os.cwd())
    """

    if debug is None:
        debug = False

    old_dir = Path('.').resolve().as_posix()

    if debug:
        print(" ** pushd %s (pwd=%s)" % (new_dir, old_dir))

    temp_dir = None # rm tempdir when storage goes out of scope
    if new_dir is None:
        root = tempfile.gettempdir()
        temp_dir = tempfile.mkdtemp(dir=root)
        os.chdir(temp_dir)
    else:
        os.chdir(new_dir)

    if debug:
        print(" ** %s: chdir(%s) from %s" % (iam(), new_dir, old_dir))

    try:
        yield

    finally:
        if debug:
            print(" ** popd %s" % new_dir)
        os.chdir(old_dir)
        if tempdir:
            shutil.rmtree(temp_dir)

    return

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
@contextlib.contextmanager
def temporary_directory():
    """Create a transient temporary directory.

    Usage:
    with temporary_directory() as temp_dir:
        ... do stuff with temp_dir ...
    """

    # suffix=None, prefix=none, dir=None
    d = tempfile.mkdtemp()
    try:
        yield d

    finally:
        from pathlib import Path
        
        print( Path('.').resolve().as_posix())
        import pdb
        pdb.set_trace()
        
        shutil.rmtree(d)

        pdb.set_trace()
        # rmtree(d)

    
# EOF
