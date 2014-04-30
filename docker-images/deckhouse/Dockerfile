FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /srv

ADD ./vendor/ /srv/bin

RUN mkdir -p /srv/serf

ENV PLUGIN_PATH /srv/serf

ADD ./bin/ /srv/bin

# Serf event handler shared by many containers
ADD ./serf/ /srv/serf/common-plugin