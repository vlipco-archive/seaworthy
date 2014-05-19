FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /usr/local/src

RUN bucket_url='https://s3.amazonaws.com/bitly-downloads/nsq' && \
	wget --quiet $bucket_url/nsq-0.2.28.linux-amd64.go1.2.1.tar.gz

RUN tar xf nsq-0.2.28.linux-amd64.go1.2.1.tar.gz
RUN cp nsq-0.2.28.linux-amd64.go1.2.1/bin/* /usr/local/bin