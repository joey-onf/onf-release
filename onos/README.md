## -----------------------------------------------------------------------
## Intent: Generate a script that will interrogate ONOS component
## repositories (pom.xml) for version data, diffs or blame info.
## -----------------------------------------------------------------------

1) Checkout an onos code repository.
2) Invoke gather-component.sh
3) find generated -ls
4) Modify generated/*/compare.sh and uncomment actions or changesets.
5) Invoke generated/*/compare.sh

# TODO
- Add command line switches to specify actions.
- 
