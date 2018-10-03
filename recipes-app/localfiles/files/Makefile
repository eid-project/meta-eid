# TODO: should be given from bitbake
bindir := /usr/bin
sysconfdir := /etc

all:
	@echo "nothing to build"

install:
	install -d $(DESTDIR)/$(bindir) $(DESTDIR)/$(sysconfdir)
	install -m 0755 hoge $(DESTDIR)/$(bindir)
	install -m 0644 hoge.conf $(DESTDIR)/$(sysconfdir)
