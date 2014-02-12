RIETVELDREV=32c87e882d9b

default:
	@echo "Run 'make all' to fetch required sources to run this example."

all: static templates codereview gae2django dev.db
	@echo "Run './manage.py runserver' to run Rietveld."

clean: clean_local clean_external

clean_external: clean_rietveld

clean_rietveld:
	@if [ -x codereview ]; then unlink codereview; fi;
	@if [ -x static ]; then unlink static; fi;
	@if [ -x templates ]; then unlink templates; fi;
	@if [ -x upload.py ]; then unlink upload.py; fi;
	@rm -rf rietveld.hg

clean_local:
	@if [ -x gae2django ]; then unlink gae2django; fi;
	@rm -f dev.db

gae2django:
	ln -s ../../gae2django .

dev.db:
	./manage.py syncdb --noinput

rietveld.hg:
	hg clone -u $(RIETVELDREV) http://code.google.com/p/rietveld rietveld.hg

codereview: rietveld.hg
	ln -s rietveld.hg/codereview .
	patch -p1 < patches/download.link.diff

static: rietveld.hg upload.py
	ln -s rietveld.hg/static .

upload.py: rietveld.hg
	ln -s rietveld.hg/upload.py .
	patch -p0 < patches/upload.diff

templates: rietveld.hg
	ln -s rietveld.hg/templates .
	patch -p1 < patches/account-login-links.diff
