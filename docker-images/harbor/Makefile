build:
	docker build -t vlipco/harbor --rm .

dev: build
	docker run -i -t -p 3333:3333 vlipco/harbor /srv/bin/dev

shell: build
	docker run -i -t -p 3333:3333 vlipco/harbor /bin/bash