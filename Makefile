BASEDIR=$(CURDIR)
OUTPUTDIR=$(BASEDIR)/_output

build: media style
	dapper build && sh $(OUTPUTDIR)/rename.sh
	rm -r _output/*/_src

media:
	media/_src/generate.sh

style:
	style/_src/generate.sh

publish: $(OUTPUTDIR)
	rsync --recursive --delete --filter='P *.*.gz' --checksum --compress --verbose --human-readable _output/ postcircumfix:~/postcircumfix.com/
	ssh postcircumfix "/usr/local/bin/gzip_static_generate ~/postcircumfix.com/"

clean:
	rm -rf $(OUTPUTDIR)

.PHONY: build publish clean media style
