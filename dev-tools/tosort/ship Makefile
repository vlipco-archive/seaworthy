environment = -e "SLUG_SERVER=172.17.42.1:9999" -e "APP_NAME=ruby"

build:
	docker build -t vlipco/harbor --rm .

dev: build
	docker run -i -t -p 3333:5000 vlipco/harbor /srv/bin/dev

shell: build
	docker run -i -t -p 3333:5000 $(environment) vlipco/harbor /bin/bash

run: build
	docker run -i -t -p 3333:5000 $(environment) vlipco/harbor