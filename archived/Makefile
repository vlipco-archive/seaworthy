# builds the builder image
builder:
	sudo docker build -t vlipco/seaworthy-builder --rm .

clean:
	rm -rf ./rpm-builds/*
	sudo docker rm -f seaworthy-builder || :

# using the builder, create the rpm-builds
rpm: builder clean
	sudo docker run -d --name seaworthy-builder vlipco/seaworthy-builder "sleep infinity"
	sudo docker cp builder:/seaworthy/out/ rpm-builds
	mv rpm-builds/out/* rpm-builds && rmdir rpm-builds/out