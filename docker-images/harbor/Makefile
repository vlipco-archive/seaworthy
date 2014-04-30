dbus_socket = /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket
geard_data = /var/lib/containers:/var/lib/containers
systemd_target = /etc/systemd/system/container-active.target.wants:/etc/systemd/system/container-active.target.wants

build:
	docker build -t vlipco/harbor .

shell: build
	docker run -i -t vlipco/harbor /bin/bash

run: build
	docker run -v $(dbus_socket) -v $(geard_data) -v $(systemd_target) -i -t vlipco/harbor /bin/bash