# Ocean liner is a hevily modified fork of flynn/slugbuilder
# created to match Vlipco needs in a serf cluster

FROM vlipco/deckhouse
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /srv

ADD ./bin/ /srv/bin
ADD ./vendor/ /srv/bin
ADD ./conf/ /srv/conf
ADD ./buildpacks/ /srv/buildpacks

# To be reused after rebuild
VOLUME ["/srv/data"]

# forego auto assigned ports for:
# git-receive & slug-serving
EXPOSE 5000
EXPOSE 5100

# Trigger's forego start
CMD /srv/bin/init