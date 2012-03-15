MAN9 := $(wildcard org_netbsd/src/share/man/man9/*.9) $(wildcard org_netbsd/src/share/man/man9/*/*.9)
DATE := $(shell env LC_ALL=C LANGUAGE=C LANG=C date)
MAN_UTF8 = $(CURDIR)/tools/man_utf8
ROFF2HTML = $(CURDIR)/tools/rofftxt2html
DIR_HTMLFILES = $(CURDIR)/tools/output_htmls_files/

all: build-stamp

update-org_netbsd:
	rm -rf org_netbsd
	mkdir -p org_netbsd
	cd org_netbsd/ && cvs -d /home/kiwamu/cvs_mirror/NetBSD-CVSROOT co src/share/man/man9
	rm -rf `find org_netbsd -name CVS`
	@echo 'po4a-gettextize...'
	@po4a-gettextize -f man $(shell for i in $(MAN9); do echo -m $$i; done) -p po/translation.pot
	@echo '! Check man pages on "org_netbsd" directory, and git commit them. !'

build-stamp: $(MAN9) po/ja.po
	cp po4a.cfg.template po4a.cfg
	@for i in $(MAN9); do echo '[type: man] ' $$i ' ' \
	`echo $$i | sed 's/org_netbsd/\$$lang:translated/' | \
	sed 's/man\/man/man\/\$$lang\/man/'` >> po4a.cfg; done
	po4a po4a.cfg
	touch $@

htmlize: build-stamp
	rm -rf html
	mkdir -p html
	for i in `find org_netbsd/ translated/ -name "*.9"`; do \
	mkdir -p html/`dirname $$i`; \
	$(MAN_UTF8) $$i | $(ROFF2HTML) $$i > html/$$i.html; done
	cd html/ && haml $(DIR_HTMLFILES)/tree.haml tree.html; \
	haml $(DIR_HTMLFILES)/index.haml index.html; \
	mkdir -p js; cp $(DIR_HTMLFILES)/*.js js/

clean:
	rm -f build-stamp
	rm -f *~

.PHONY: all clean update-orig htmlize
