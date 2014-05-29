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

    waypoint: ./waypoint
public_harbor: ./public_harbor
private_harbor: ./private_harbor


sudo docker run --name admiral -i -t -d -p 7649:7649 -p 7649:7649/udp -e SERF_ROUTABLE_IP=172.17.42.1 -e SERF_NODE_NAME=admiral -e SERF_BIND_PORT=7649 -e SERF_JOIN_NODE=172.17.42.1:7649 -e SERF_ROLE=admiral vlipco/deckhouse /srv/bin/start-serf


sudo docker run --name waypoint -i -t -d -p 7650:7650 -p 7650:7650/udp -e SERF_ROUTABLE_IP=172.17.42.1 -e SERF_NODE_NAME=waypoint -e SERF_BIND_PORT=7650 -e SERF_JOIN_NODE=172.17.42.1:7649 -e SERF_ROLE=waypoint -p 5000:5000 -p 5100:5100 vlipco/waypoint


sudo docker run --name public_harbor -i -t -d -p 7651:7651 -p 7651:7651/udp -e SERF_ROUTABLE_IP=172.17.42.1 -e SERF_NODE_NAME=public_harbor -e SERF_BIND_PORT=7651 -e SERF_TAGS=group=public -e SERF_JOIN_NODE=172.17.42.1:7649 -e SERF_ROLE=harbor -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -v /var/lib/containers:/var/lib/containers -v /etc/systemd/system/container-active.target.wants:/etc/systemd/system/ vlipco/harbor


sudo docker run --name internal_harbor -i -t -d -p 7652:7652 -p 7652:7652/udp -e SERF_ROUTABLE_IP=172.17.42.1 -e SERF_NODE_NAME=internal_harbor -e SERF_BIND_PORT=7652 -e SERF_TAGS=group=internal -e SERF_JOIN_NODE=172.17.42.1:7649 -e SERF_ROLE=harbor -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -v /var/lib/containers:/var/lib/containers -v /etc/systemd/system/container-active.target.wants:/etc/systemd/system/ vlipco/harbor


#docker run --rm -ti -p 5000:5000 -p 5100:5100 --dns 8.8.8.8 --dns 8.8.4.4 vlipco/waypoint /bin/bash


#Type=simple
#EnvironmentFile=-/etc/default/gear

# GearD defaults file

# Modify the docker socket that GearD should connect to
#GEARD_OPTS='--docker-socket="unix:///var/run/docker.sock"'

# Enable if docker supports the experimental env-file directive
#GEARD_OPTS="${GEARD_OPTS} --has-env-file"

# Enable if docker supports the experimental foreground mode
#GEARD_OPTS="${GEARD_OPTS} --has-foreground"

# Specify the directory containing the server private key and trusted client public keys
#GEARD_OPTS="${GEARD_OPTS} --key-path=''"

# Set the address for the http endpoint to listen on
#GEARD_OPTS="${GEARD_OPTS} --listen-address=':43273'"

fileserver on ruby buildpack folder
 sti build . vlipco/hull ruby1 -shttp://10.0.77.50:5100/sti

 http://localhost:5100/sti

 sudo useradd -m -U -r -s /bin/bash git -d /var/git
 command="GITUSER=git /usr/local/bin/gitreceive run vagrant_pub dd:3b:b8:2e:85:04:06:e9:ab:ff:a8:0a:c0:04:6e:d6",no-agent-forwarding,no-pty,no-user-rc,no-X11-forwarding,no-port-forwarding ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key