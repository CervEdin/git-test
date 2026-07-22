PREFIX ?= /usr/local
bindir = $(PREFIX)/bin
mandir = $(PREFIX)/share/man

INSTALL = install

.PHONY: install uninstall

install:
	$(INSTALL) -d $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 git-test $(DESTDIR)$(bindir)/git-test
	$(INSTALL) -d $(DESTDIR)$(mandir)/man1
	$(INSTALL) -m 644 git-test.1 $(DESTDIR)$(mandir)/man1/git-test.1

uninstall:
	rm -f $(DESTDIR)$(bindir)/git-test
	rm -f $(DESTDIR)$(mandir)/man1/git-test.1

.PHONY: test

SHELLS = /bin/bash /bin/ksh /bin/mksh /bin/pdksh /bin/dash

test:
	fail=0; \
	for shell in $(SHELLS); do \
		test -x $$shell || { echo "skipping $$shell (not installed)"; continue; }; \
		echo $$shell; \
		bash test.sh -v -s $$shell || fail=1; \
	done; \
	exit $$fail
