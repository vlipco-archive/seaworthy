# This is the base of all other container
# It exists to share commong things like pre-installed pkgs

FROM progrium/cedarish
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /srv/
ENV PATH /srv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ADD ./vendor/ /srv/bin
ADD ./conf/bashrc /root/.bashrc
RUN mkdir -p /srv
RUN ln -s /root/.bashrc /.bashrc
