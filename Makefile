VERSION=0.1

.SILENT:

.PHONY: build
build:
	docker build -t lukezbihlyj/snex:$(VERSION) .

.PHONY: push
push: build
	docker push lukezbihlyj/snex:$(VERSION)
