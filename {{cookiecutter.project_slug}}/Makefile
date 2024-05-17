#
# Author: {{ cookiecutter.author_name }}

SHELL = /bin/sh
.DEFAULT_GOAL := help

export VCS_URL    := $(shell git config --get remote.origin.url 2> /dev/null || echo unversioned repo)
export VCS_REF    := $(shell git rev-parse --short HEAD 2> /dev/null || echo unversioned repo)
export VCS_STATUS := $(if $(shell git status -s 2> /dev/null || echo unversioned repo),'modified/untracked','clean')
export BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

export DOCKER_IMAGE_NAME ?= {{ cookiecutter.project_name.lower().replace(' ', '-') }}
export DOCKER_IMAGE_TAG  ?= $(shell cat VERSION 2> /dev/null || echo undefined)

export COMPOSE_INPUT_DIR  := ./validation/input
export COMPOSE_OUTPUT_DIR := .tmp/output

OSPARC_DIR:=$(CURDIR)/.osparc

# INTEGRATION -----------------------------------------------------------------
METADATA := .osparc/metadata.yml


.PHONY: VERSION
VERSION: $(METADATA) ## generates VERSION from metadata
	# updating $@ from $<
	@$(OSPARC_DIR)/bin/ooil.bash get-version --metadata-file $< > $@

service.cli/run: $(METADATA) ## generates run from metadata
	# Updates adapter script from metadata in $<
	@$(OSPARC_DIR)/bin/ooil.bash run-creator --metadata $< --runscript $@

docker-compose.yml: $(METADATA) ## generates docker-compose
	# Injects metadata from $< as labels
	@$(OSPARC_DIR)/bin/ooil.bash compose --to-spec-file $@ --metadata $<

# BUILD -----------------------------------------------------------------

define _docker_compose_build
export DOCKER_BUILD_TARGET=$(if $(findstring -devel,$@),development,$(if $(findstring -cache,$@),cache,production)); \
	docker compose -f docker-compose.yml build $(if $(findstring -nc,$@),--no-cache,);
endef


.PHONY: build build-devel build-nc build-devel-nc
build build-devel build-nc build-devel-nc: VERSION docker-compose.yml service.cli/run ## builds image
	# building image local/${DOCKER_IMAGE_NAME}...
	@$(call _docker_compose_build)

define show-meta
	$(foreach iid,$(shell docker images */$(1):* -q | sort | uniq),\
		docker image inspect $(iid) | jq '.[0] | .RepoTags, .ContainerConfig.Labels, .Config.Labels';)
endef


.PHONY: info-build
info-build: ## displays info on the built image
	# Built images
	@docker images */$(DOCKER_IMAGE_NAME):*
	# Tags and labels
	@$(call show-meta,$(DOCKER_IMAGE_NAME))


	docker compose build

# To test built service locally -------------------------------------------------------------------------
.PHONY: run-local
run-local:	## runs image with local configuration
	docker compose --file docker-compose-local.yml up

.PHONY: publish-local
publish-local: ## push to local oSPARC to test integration. It requires the oSPARC platform running on your computer, you can find more information here: https://github.com/ITISFoundation/osparc-simcore/blob/master/README.md
	docker tag simcore/services/comp/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} registry:5000/simcore/services/comp/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
	docker push registry:5000/simcore/services/comp/$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)
	@curl registry:5000/v2/_catalog | jq

.PHONY: help
help: ## this colorful help
	@echo "Recipes for '$(notdir $(CURDIR))':"
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[[:alpha:][:space:]_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""


# COOKIECUTTER -----------------------------------------------------------------

.PHONY: replay
replay: .cookiecutterrc ## re-applies cookiecutter
	# Replaying {{ cookiecutter._template }} ...
	@cookiecutter --no-input --overwrite-if-exists \
		--config-file=$< \
		--output-dir="$(abspath $(CURDIR)/..)" \
		"{{ cookiecutter._template }}"


.PHONY: info
info: ## general info
	# env vars: version control
	@echo " VCS_URL                     : $(VCS_URL)"
	@echo " VCS_REF                     : $(VCS_REF)"
	@echo " VCS_STATUS                  : $(VCS_STATUS)"
	# env vars: docker
	@echo " DOCKER_IMAGE_TAG            : $(DOCKER_IMAGE_TAG)"
	@echo " BUILD_DATE                  : $(BUILD_DATE)"
	# exe: recommended dev tools
	@echo ' git                         : $(shell git --version 2>/dev/null || echo not found)'
	@echo ' make                        : $(shell make --version 2>&1 | head -n 1)'
	@echo ' jq                          : $(shell jq --version 2>/dev/null || echo not found z)'
	@echo ' awk                         : $(shell awk -W version 2>&1 | head -n 1 2>/dev/null || echo not found)'
	@echo ' python                      : $(shell python3 --version 2>/dev/null || echo not found )'
	@echo ' docker                      : $(shell docker --version)'
	@echo ' docker buildx               : $(shell docker buildx version)'
	@echo ' docker compose              : $(shell docker compose --version)'

# MISC -----------------------------------------------------------------


.PHONY: clean
git_clean_args = -dxf --exclude=.vscode/

clean: ## cleans all unversioned files in project and temp files create by this makefile
	# Cleaning unversioned
	@git clean -n $(git_clean_args)
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo -n "$(shell whoami), are you REALLY sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@git clean $(git_clean_args)