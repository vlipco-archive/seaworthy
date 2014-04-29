FROM vlipco/hull
MAINTAINER David Pelaez <david@vlipco.co>

WORKDIR /srv

ADD ./bin/ /srv/bin

RUN mkdir -p /app

# For caching
VOLUME ["/srv/data"]

# TODO env variable for the exposed port
# TODO entrypoint
# TODO demand SLUG_SERVER, SLUG_SERVER_PORT

# in case the app needs to listen to the outside
EXPOSE 5000

CMD /srv/bin/init