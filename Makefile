PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
SCRIPT = zj

.PHONY: install uninstall symlink

install:
	install -d $(BINDIR)
	install -m 755 $(SCRIPT) $(BINDIR)/$(SCRIPT)

uninstall:
	rm -f $(BINDIR)/$(SCRIPT)

symlink:
	install -d $(BINDIR)
	ln -sf $(CURDIR)/$(SCRIPT) $(BINDIR)/$(SCRIPT)
