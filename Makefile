#
#  Only used to build distribution tarballs.
#
DIST_PREFIX = ${TMP}
VERSION     = 0.6
BASE        = node-reverse-proxy

#
#  For indenting
#
JSOPTS=--brace-style=expand

#
#  Show the available targets
#
nop:
	@echo "Valid targets are"
	@echo ""
	@echo " clean - Remove editor files"
	@echo " tidy  - Indent code"
	@echo " test  - Run Steve's tests"


#
#  Remove any editor files.
#
clean:
	@find . \( -name '*.bak' -o -name '*~' \) -delete


#
#  Make a new release tarball, and make a GPG signature.
#
release: tidy clean
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	rm -f $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz
	cp -R . $(DIST_PREFIX)/$(BASE)-$(VERSION)
	perl -pi.bak -e "s/UNRELEASED/$(VERSION)/g" $(DIST_PREFIX)/$(BASE)-$(VERSION)/node-reverse-proxy.js
	rm  $(DIST_PREFIX)/$(BASE)-$(VERSION)/*.bak
	rm  $(DIST_PREFIX)/$(BASE)-$(VERSION)/rewrites.js
	find  $(DIST_PREFIX)/$(BASE)-$(VERSION) -name ".hg*" -print | xargs rm -rf
	find  $(DIST_PREFIX)/$(BASE)-$(VERSION) -name ".release" -print | xargs rm -rf
	cd $(DIST_PREFIX) && tar -cvf $(DIST_PREFIX)/$(BASE)-$(VERSION).tar $(BASE)-$(VERSION)/
	gzip $(DIST_PREFIX)/$(BASE)-$(VERSION).tar
	mv $(DIST_PREFIX)/$(BASE)-$(VERSION).tar.gz .
	rm -rf $(DIST_PREFIX)/$(BASE)-$(VERSION)
	gpg --armour --detach-sign $(BASE)-$(VERSION).tar.gz
	echo $(VERSION) > .version

#
#  If we have test cases, run them
#
test:
	@./tests/run-tests


#
#  Tidy our Javascript file(s).
#
jslint:
	python ./util/jsbeautifier.py --brace-style=expand node-reverse-proxy.js > $$; mv $$ node-reverse-proxy.js
	[ -e rewrites.js ] && python ./util/jsbeautifier.py --brace-style=expand rewrites.js > $$; mv $$ rewrites.js


#
#  Tidy the (steve-specific?) Perl test code.
#
perltidy:
	@[ -x /usr/bin/perltidy ]    && perltidy ./tests/run-tests


#
#  Indent our code consistently.
#
tidy: jslint perltidy


#
#  Steve's personal deployer.  Nice.
#
deploy:
	rsync -vazr *.js root@steve.org.uk://etc/service/node-reverse-proxy/
