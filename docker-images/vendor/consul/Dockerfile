FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /usr/local/src
RUN wget --quiet https://dl.bintray.com/mitchellh/consul/0.2.0_linux_amd64.zip
RUN unzip 0.2.0_linux_amd64.zip && chmod +x consul && mv consul /usr/local/bin/
CMD ["/usr/local/bin/consul"]