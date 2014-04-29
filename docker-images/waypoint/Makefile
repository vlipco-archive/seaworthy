port_opts = -p 6666:5000 -p 9999:5100
volumes_opts = -v /home/docker/waypoint:/srv/data:rw
image = vlipco/waypoint
ctr_name = waypoint

build:
	docker build -t $(image) --rm .

dev: build
	docker run --rm $(volumes_opts) -i -t $(port_opts) $(image) /srv/bin/dev

clean:
	docker stop $(ctr_name) || true
	docker rm --volumes=true $(ctr_name) || true

run: build
	@echo "Stopping previous container"
	@docker stop $(ctr_name) || echo "WARN: Stopped failed, maybe it wasn't running"
	@echo "Removing previous container"
	@docker rm --volumes=false $(ctr_name) || echo "WARN: Remove failed, maybe there was no predecessor"
	docker run --name $(ctr_name) --rm -i -t $(port_opts) $(volumes_opts) $(image)

run-alone: build
	docker run $(port_opts) -i -t $(image)	

shell: build
	docker run --rm $(volumes_opts) -i -t $(image) /bin/bash