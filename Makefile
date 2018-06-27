.PHONY: help test

VERSION ?= `cat VERSION`
IMAGE_NAME ?= xuxxux/python-s2i-alpine-base

help:
	@echo "$(IMAGE_NAME):$(VERSION)"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

debug: ## Test the Docker image
	docker run --rm -it $(IMAGE_NAME):$(VERSION) /bin/sh

build: ## Rebuild the Docker image
	docker build --force-rm -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):latest .

example_gunicorn_pipenv: build ## build example docker image with pipenv
	s2i build https://github.com/neuhalje/python-s2i-alpine-base --context-dir=examples/pipenv-test-app/ $(IMAGE_NAME):$(VERSION) python-sample-app-pipenv
	@echo ""
	@echo "   ----------   ----------   -------------   -----------"
	@echo ""
	@echo "Start the example app with"
	@echo "docker run -p8080:8080 python-sample-app-pipenv"

example_gunicorn: build ## build example docker image
	s2i build https://github.com/neuhalje/python-s2i-alpine-base --context-dir=examples/setup-test-app/ $(IMAGE_NAME):$(VERSION) python-sample-app
	@echo ""
	@echo "   ----------   ----------   -------------   -----------"
	@echo ""
	@echo "Start the example app with"
	@echo "docker run -p8080:8080 python-sample-app"

release: build ## Rebuild and release the Docker image to Docker Hub
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):latest
