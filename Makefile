PREFIX ?= /usr/local

.PHONY: test install uninstall

test:
	./test.sh

install:
	install -m 755 transparent-sops $(DESTDIR)$(PREFIX)/bin/transparent-sops

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/transparent-sops
