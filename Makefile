PKG     := wifi-cli
VERSION := $(shell sed -n 's/^Version: //p' debian/control)
DESTDIR ?=
PREFIX  ?= /usr
SBINDIR ?= $(PREFIX)/sbin
BUILD   := build/$(PKG)_$(VERSION)_all

.PHONY: all install uninstall deb rpm dist clean check

all: check

check:
	bash -n bin/wifi
	@command -v shellcheck >/dev/null && shellcheck -s bash bin/wifi || echo "(shellcheck not installed, skipped)"

install:
	install -D -m 755 bin/wifi                 $(DESTDIR)$(SBINDIR)/wifi
	install -D -m 644 systemd/80-wifi-cli.network $(DESTDIR)$(PREFIX)/lib/systemd/network/80-wifi-cli.network
	install -D -m 644 LICENSE                  $(DESTDIR)$(PREFIX)/share/doc/$(PKG)/copyright
	install -D -m 644 README.md                $(DESTDIR)$(PREFIX)/share/doc/$(PKG)/README.md
	install -D -m 644 docs/INTERNALS.md        $(DESTDIR)$(PREFIX)/share/doc/$(PKG)/INTERNALS.md
	install -D -m 644 man/wifi.8               $(DESTDIR)$(PREFIX)/share/man/man8/wifi.8

uninstall:
	rm -f $(DESTDIR)$(SBINDIR)/wifi \
	      $(DESTDIR)$(PREFIX)/lib/systemd/network/80-wifi-cli.network \
	      $(DESTDIR)$(PREFIX)/share/man/man8/wifi.8
	rm -rf $(DESTDIR)$(PREFIX)/share/doc/$(PKG)

deb: check
	rm -rf $(BUILD)
	$(MAKE) install DESTDIR=$(BUILD)
	install -d -m 755 $(BUILD)/DEBIAN
	install -m 644 debian/control $(BUILD)/DEBIAN/control
	install -m 755 debian/postinst debian/postrm $(BUILD)/DEBIAN/
	cd $(BUILD) && find usr -type f -exec md5sum {} + > DEBIAN/md5sums
	gzip -9n $(BUILD)/usr/share/man/man8/wifi.8
	dpkg-deb --root-owner-group --build $(BUILD) build/
	@ls -1 build/*.deb

dist: check
	mkdir -p build
	tar --exclude=build --exclude=.git --transform 's,^,$(PKG)/,' -czf build/$(PKG)-$(VERSION).tar.gz \
	    bin systemd debian packaging man docs Makefile README.md LICENSE CHANGELOG.md CONTRIBUTING.md
	@ls -1 build/*.tar.gz

rpm: dist
	mkdir -p build/rpm/SOURCES build/rpm/SPECS
	cp build/$(PKG)-$(VERSION).tar.gz build/rpm/SOURCES/
	cp packaging/$(PKG).spec build/rpm/SPECS/
	rpmbuild --define "_topdir $(CURDIR)/build/rpm" -ba build/rpm/SPECS/$(PKG).spec
	@ls -1 build/rpm/RPMS/noarch/*.rpm

clean:
	rm -rf build
