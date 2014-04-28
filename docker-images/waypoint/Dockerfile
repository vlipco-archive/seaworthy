# Ocean liner is a hevily modified fork of flynn/slugbuilder
# created to match Vlipco needs in a serf cluster

FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /srv

ADD ./bin/ /srv/bin
ADD ./vendor/ /srv/bin
ADD ./conf/ /srv/conf
ADD ./buildpacks/ /srv/buildpacks

# To be reused after rebuild
VOLUME ["/srv/data"]

# for git-receive
EXPOSE 9999

# for slug-serving with shelf
EXPOSE 6666

# TODO set forego with Procfile as entrypoint
