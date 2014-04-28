build:
	docker build -t ocean-liner --rm .

dev: build
	docker run -i -t -p 9292:22 ocean-liner /srv/bin/dev

shell: build
	docker run -i -t -p 9292:22 ocean-liner /bin/bash