#!/usr/bin/env python
## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
'''Unit test for file_utils.py.'''

##-------------------##
##---]  GLOBALS  [---##
##-------------------##

##-------------------##
##---]  IMPORTS  [---##
##-------------------##
import pprint
import unittest
import tempfile

from pathlib           import Path
from probe.main.file_utils   import pushd, tempdir


class TestStringMethods(unittest.TestCase):

    ## -----------------------------------------------------------------------
    ## -----------------------------------------------------------------------
    def test_tempdir(self):

        start = Path('.').resolve().as_posix()

        with tempdir():  
            tmp = Path('.').resolve().as_posix()
            self.assertEqual(tmp, start)

        persist = tempdir()
        self.assertNotEqual(start, persist.path)
                
    ## -----------------------------------------------------------------------
    ## -----------------------------------------------------------------------
    def test_pushd(self):

        start = Path('.').resolve().as_posix()

        for path in [ tempfile.gettempdir(), None ]:
            with pushd(path=path):  
                pwd = Path('.').resolve().as_posix()
                self.assertNotEqual(pwd, start)

##----------------##
##---]  MAIN  [---##
##----------------##
if __name__ == "__main__":
    main()

# [EOF]
