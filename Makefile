
.PHONY: build
build:
	python setup.py build
	pip install $(GTRON_PIP_OPTIONS) -e .

.PHONY: venv
venv:
	@echo Build test_venv
	rm -rf test_venv
	virtualenv test_venv
	(. test_venv/bin/activate; pip install --upgrade pip)

.PHONY: test_dep
test_dep:
	$(MAKE) venv
	(. test_venv/bin/activate; GTRON_PIP_OPTIONS="--no-deps" gtron --force build $(REQUIRED_GTRON_TOOLS) ; $(MAKE);)
	(. test_venv/bin/activate; $(MAKE) test;)

.PHONY: sdist
sdist:
	@echo Building source distribution
	python setup.py build sdist

.PHONY: test_sdist
test_sdist:
	$(MAKE) venv
	$(MAKE) sdist
	@echo Installing distribution in clean venv.  This will take a while...
	(. test_venv/bin/activate; pip install dist/*-$$(cat VERSION.txt).tar.gz );
	(. test_venv/bin/activate; $(MAKE) test)

deploy_requirements.txt:
	$(MAKE) test_dep
	(. test_venv/bin/activate; pip freeze > $@)

.PHONY: core_distclean
core_distclean:
	rm -rf test_venv
	rm -rf .eggs

.PHONY: clean
clean:

distclean: core_distclean


.PHONY:test
test: 
	python -m unittest discover -v test

.PHONY: doc
doc: build $(wildcard doc/*.rst)
	$(MAKE) -C doc html

.PHONY: doczip
doczip: doc
	T=$$PWD; (cd doc/_build/html; zip -r $$T/Swoop-$$(cat $$T/VERSION.txt)-docs.zip *)

.PHONY: diff
diff: 
	diff Swoop/eagle-7.2.0.dtd Swoop/eagle-swoop.dtd > Swoop/eagle.dtd.diff

.PHONY: release
release: clean
	touch VERSION.txt
	git commit -m "Commit before release $$(cat VERSION.txt)" -a
	git push
	git checkout release
	git merge --no-ff master
	git tag -a $$(cat VERSION.txt) -m "Tag version $$(cat VERSION.txt)"
	git push --follow-tags
	$(MAKE) test_sdist
	python setup.py sdist upload
	$(MAKE) doczip

clean:
	rm -rf Swoop/eagleDTD.py
	rm -rf test/inputs/*.broken.xml
	rm -rf Swoop/Swoop.py
	if [ -d doc ]; then $(MAKE) -C doc clean; fi
	rm -rf *~
	rm -rf .eggs
	rm -rf Swoop.egg-info
	rm -rf build 
	find . -name '*.pyc' | xargs rm -rf
