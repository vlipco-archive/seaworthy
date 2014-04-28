# This is the base of all other container
# It exists to share commong things like pre-installed pkgs

FROM progrium/cedarish
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /srv

RUN mkdir -p /srv
ADD ./vendor/ /srv/bin

#ADD ./bin/ /srv/bin
#ADD ./conf/ /srv/conf

ENV PATH /srv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin