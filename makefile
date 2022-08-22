.PHONY: help build
.DEFAULT_GOAL := help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ----------------------------------------------------------------------------------------------------------------

install: ## Installs all dependencies
	docker pull orcabuilder/orca:latest
	curl -L https://www.svrunit.com/downloads/svrunit.zip --output svrunit.zip
	unzip -o svrunit.zip
	rm -f svrunit.zip

clear: ## Clears all dangling images
	rm -rf ./src/dist
	docker images -aq -f 'dangling=true' | xargs docker rmi
	docker volume ls -q -f 'dangling=true' | xargs docker volume rm

# ----------------------------------------------------------------------------------------------------------------

generate: ## Generates all artifacts for this image. You can use the local PHAR with: make generate phar=1
	docker run -v "${PWD}/src:/opt/project" orcabuilder/orca:latest

# ----------------------------------------------------------------------------------------------------------------

build: ## Builds the provided tag [image=php tag=8.1]
ifndef tag
	$(warning Provide the required image tag using "make build image=php tag=8.1")
	@exit 1;
else
	@cd ./src/dist/images/$(image)/$(tag) && DOCKER_BUILDKIT=1 docker build -t nevercodealone/$(image):$(tag) .
endif

test: ## Runs all SVRUnit Test Suites for the provided image and tag
ifndef tag
	$(warning Provide the required image tag using "make test image=php tag=8.1")
	@exit 1;
else
	php svrunit.phar --configuration=./tests/svrunit/$(image)/$(tag)/config.xml --stop-on-error --debug --report-junit --report-html
endif