# -*- makefile -*-

proj := voltha
vers := 9999999.11

# mk-args	+= --tag $(proj)-$(vers)
mk-args	+= --project $(proj)
mk-args	+= --release-version $(vers)

all:
	./mkrelease.py $(mk-args)

clean:
	$(RM) -r voltha-release

# [EOF]
