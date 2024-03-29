# -*- makefile -*-
## -----------------------------------------------------------------------
## Intent: Targets in this makefile will clone all voltha repositories
##         and will invoke a list of makefile targets against each.
## -----------------------------------------------------------------------

check += license
check += versions-chart
check += voltha-protos

.PHONY: $(check)

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
all:

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
edit:
	./edit.sh

## -----------------------------------------------------------------------
## Intent: Iterate and perform validation checks
## -----------------------------------------------------------------------
check : $(check)
$(check) : sandbox
	$(MAKE) -C $@ check

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
sandbox:
	./sandbox.sh

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
clean ::
	$(RM) -r branches
	$(RM) -r sandbox

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
sterile :: clean

## -----------------------------------------------------------------------
## -----------------------------------------------------------------------
help:
	@echo "USAGE: $(MAKE)"
	@printf '  %-30.30s %s\n' 'sandbox'\
	  'Clone all voltha repos for validation'
	@printf '  %-30.30s %s\n' 'edit'\
	  'Load files of interest into an editor'

	@printf '  %-30.30s %s\n' 'check'\
	  'Iterate over subdirs and perform repository validation checks'

# [EOF]

