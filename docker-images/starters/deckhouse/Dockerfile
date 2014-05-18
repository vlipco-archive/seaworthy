FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>
ADD ./vendor/ /usr/local/src
ADD ./deckhouse-provisioner /usr/local/docker
RUN /usr/local/docker/deckhouse-provisioner
