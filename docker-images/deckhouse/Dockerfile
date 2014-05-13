FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

ADD ./vendor/ /usr/local/bin
ADD ./bin/ /usr/local/bin

RUN mkdir -p /srv/serf

# Serf event handlers shared by many containers
ADD ./serf/ /srv/serf/common-plugin