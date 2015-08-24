BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/_output

build:
	dapper build && sh $(OUTPUTDIR)/rename.sh

publish: $(OUTPUTDIR)
	rsync -avzhe ssh _output/ postcircumfix:~/postcircumfix.com/

clean: 
	rm -rf $(OUTPUTDIR)

.PHONY: build publish clean
