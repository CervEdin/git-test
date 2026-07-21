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
