# -*- python -*-
## -----------------------------------------------------------------------
## Intent: This module contains general helper methods
## -----------------------------------------------------------------------

##-------------------##
##---]  IMPORTS  [---##
##-------------------##
import os

# import contextlib
from contextlib        import contextmanager
from contextlib        import ContextDecorator
from pathlib           import Path

import tempfile
from shutil            import rmtree

## -----------------------------------------------------------------------
## Intent Create a transient temp directory with automated cleanup.
## -----------------------------------------------------------------------
## Usage:
##    with tempdir() as tmp:
##        print(tmp)
##        do_something
## -----------------------------------------------------------------------
class tempdir(ContextDecorator):

    def __init__(self):
        self.path = tempfile.mkdtemp()

    def __enter__(self):
        return self.path

    def __exit__(self, exc_type, exc, exc_tb):
        rmtree(self.path)

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
@contextmanager
def pushd(path=None):
    """Closure: chdir with state retention.
       o chdir into a target directory to perform a task then return.
       o if path= not passed 
        
    :param path: Target directory name
    :type  path: string
        
    :return  context with pwd=argument passed
    :rtype:
    """

    prev = Path('.').resolve().as_posix()
    try:
        with tempdir() as tmp:
            if path is None:
                path = tmp
            os.chdir(path)
            yield
    finally:
        os.chdir(prev)

# [SEE ALSO]
# -----------------------------------------------------------------------
# https://docs.python.org/3/library/contextlib.html#contextlib.contextmanager        
# -----------------------------------------------------------------------

# EOF
