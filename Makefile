PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
SCRIPT = zj
BUMP ?= minor

.PHONY: install uninstall symlink tag

install:
	install -d $(BINDIR)
	install -m 755 $(SCRIPT) $(BINDIR)/$(SCRIPT)

uninstall:
	rm -f $(BINDIR)/$(SCRIPT)

symlink:
	install -d $(BINDIR)
	ln -sf $(CURDIR)/$(SCRIPT) $(BINDIR)/$(SCRIPT)

tag:
	@YEAR=$$(date +%Y); \
	LATEST=$$(git tag -l "$$YEAR.*" | sort -V | tail -n1); \
	if [ -z "$$LATEST" ]; then \
		NEXT="$$YEAR.1.0"; \
	else \
		MINOR=$$(echo $$LATEST | cut -d. -f2); \
		PATCH=$$(echo $$LATEST | cut -d. -f3); \
		if [ "$(BUMP)" = "patch" ]; then \
			NEXT="$$YEAR.$$MINOR.$$(($$PATCH + 1))"; \
		else \
			NEXT="$$YEAR.$$(($$MINOR + 1)).0"; \
		fi; \
	fi; \
	echo "Tagging $$NEXT..."; \
	git tag "$$NEXT" && echo "Created tag $$NEXT."
	@echo "To push this tag to the remote, run: git push origin --tags"
