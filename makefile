# -*- makefile -*-
## -----------------------------------------------------------------------
## -----------------------------------------------------------------------

all:

edit:
	./edit.sh

versions:
	./sandbox.sh
	find sandbox/ -name 'Chart.yaml' \
	    | xargs grep -i appVersion \
	    | awk -F\# '{print $1}' \
	    | grep -i appversion \
	    | tr ':' '\t'

sandbox:
	./sandbox.sh

clean:
	$(RM) -r branches
	$(RM) -r voltha-helm-charts
	$(RM) -r sandbox

help:
	@echo "USAGE: $(MAKE)"
	@echo "  edit       Load files of interest into the editor"
	@echo "  sandbox    Clone all voltha repos"
	@echo "  versions   Display Chart.yaml and app versions"

# [EOF]

