BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/_output

build:
	dapper build && sh $(OUTPUTDIR)/rename.sh
	rm -r _output/*/_src

publish: $(OUTPUTDIR)
	rsync -avzh --delete _output/ postcircumfix:~/postcircumfix.com/
	

clean: 
	rm -rf $(OUTPUTDIR)

.PHONY: build publish clean
