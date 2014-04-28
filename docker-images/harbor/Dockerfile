FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /srv

ADD ./bin/ /srv/bin

# For caching
VOLUME ["/srv/app"]

# TODO env variable for the exposed port
# TODO entrypoint
# TODO demand SLUG_SERVER, SLUG_SERVER_PORT

# in case the app needs to listen to the outside
EXPOSE 5000