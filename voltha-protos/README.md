Intro
=====

Scripts in this directory will validate the version of library voltha-protos
is consistent across all VOLTHA repository go.mod files.

Version string overrides
========================

- overrides/voltha-proto/VERSION
    - If the master branch version string is unusable for checking (ie: 1.1.0-dev)
      an explicit hardcoded version string can be introduced for checking.
      To revert to master branch checking simply delete the override file.