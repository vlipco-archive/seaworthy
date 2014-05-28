# Ocean liner is a hevily modified fork of flynn/slugbuilder
# created to match Vlipco needs in a serf cluster

FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

ADD ./bin/ /usr/local/bin
ADD ./vendor/ /usr/local/bin

ADD ./conf/ /srv/conf
ADD ./buildpacks/ /srv/buildpacks

# To be reused after rebuild
VOLUME ["/srv/data"]

# git-receive & slug-serving
EXPOSE 5000
EXPOSE 5100

# multi-init using Procfile
CMD ["/usr/local/bin/shoreman", "/srv/conf/Procfile"]
