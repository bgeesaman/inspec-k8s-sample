SHELL := /usr/bin/env bash

IMAGENAME=inspec-k8s-runner
IMAGEREPO=bgeesaman/$(IMAGENAME)
WORKDIR=/share

DOCKERBUILD=docker build -t $(IMAGEREPO):latest .
COMMAND=docker run --rm -it -v `pwd`:$(WORKDIR) -v $(HOME)/.kube:/root/.kube:ro 
IMAGEPATH=$(IMAGEREPO):latest
INSPECRUN=$(COMMAND) $(IMAGEPATH) exec . -t k8s://
DEBUGSHELL=$(COMMAND) --entrypoint /bin/bash $(IMAGEPATH)

build:
	@echo "Building $(IMAGEREPO):latest"
	@$(DOCKERBUILD)
run:
	@echo "Running in $(IMAGEREPO):latest: inspec exec . -t k8s://"
	@$(INSPECRUN)
shell:
	@echo "Running a shell inside the container"
	@$(DEBUGSHELL)

.PHONY: build run shell
