port = 7951

build:
    docker build -t vlipco/deckhouse .

shell: build
    docker run -i -t vlipco/deckhouse /bin/bash

omega:
    docker run -i -t -p $(port):$(port) -p $(port):$(port)/udp -e "SERF_ROUTABLE_IP=10.0.2.15" -e "SERF_NODE_NAME=omega" -e "SERF_BIND_PORT=$(port)" -e "SERF_JOIN_NODE=10.0.2.15:7946" -e "SERF_ROLE=deckhouse" vlipco/deckhouse /srv/bin/start-serf

container-active.target.wants

build:
    docker build -t vlipco/harbor .

shell: build
    docker run -i -t vlipco/harbor /bin/bash

run: build
    docker run #{gear_volumes} -i -t vlipco/harbor /bin/bash

build:
    docker build -t vlipco/hull --rm .

shell: build
    docker run -i -t vlipco/hull /bin/bash