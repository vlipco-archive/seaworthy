FROM vlipco/deckhouse
MAINTAINER David Pelaez <david@vlipco.co>

# Serf event handler shared by many containers
ADD ./serf/ /srv/serf/harbor-plugin

CMD /srv/bin/start-serf