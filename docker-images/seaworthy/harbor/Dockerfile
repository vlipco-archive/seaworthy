FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

# Serf event handler shared by many containers
ADD ./serf/ /srv/serf/harbor-plugin
ADD ./conf/ /srv/conf

CMD ["/usr/local/bin/shoreman", "/srv/conf/Procfile"]
