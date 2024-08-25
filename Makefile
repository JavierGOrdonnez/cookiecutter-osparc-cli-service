#
# CONVENTIONS:
#
# - targets shall be ordered such that help list rensembles a typical workflow, e.g. 'make devenv tests'
# - add doc to relevant targets
# - internal targets shall start with '.'
# - KISS
#
SHELL = /bin/bash
.DEFAULT_GOAL := help


OUTPUT_DIR := $(if $(COOCKIECUTTER_OUTPUT_DIR),$(COOCKIECUTTER_OUTPUT_DIR),$(CURDIR)/.output)
TEMPLATE = $(CURDIR)
VERSION := $(shell cat VERSION)

# PYTHON ENVIRON ---------------------------------------------------------------------------------------
.PHONY: devenv
.venv:
	@python3 --version
	python3 -m venv $@
	# upgrading package managers
	$@/bin/pip install --upgrade \
		pip \
		wheel \
		setuptools

devenv: .venv  ## create a python virtual environment with tools to dev, run and tests cookie-cutter
	# installing extra tools
	@$</bin/pip3 install pip-tools
	# your dev environment contains
	@$</bin/pip3 list
	@echo "To activate the virtual environment, run 'source $</bin/activate'"

# Upgrades and tracks python packages versions installed in the service ---------------------------------
requirements: devenv ## runs pip-tools to build requirements.txt (installed in the local virtualenv)
	@echo "If pip-compile not found, make sure you have activated the virtual environment by running 'source $</bin/activate'"
	# freezes requirements
	pip-compile requirements-dev.in --resolver=backtracking --output-file requirements-dev.txt
	pip install -r requirements-dev.txt

# TESTS -------------------------------------------------

.PHONY: tests
tests: ## tests backed cookie and image build
	@pytest -vv \
		--basetemp=$(CURDIR)/tmp \
		--exitfirst \
		--failed-first \
		--durations=0 \
		$(CURDIR)/tests/test_bake_project.py
	@pytest -o log_cli=True -vv \
		--basetemp=$(CURDIR)/tmp \
		--exitfirst \
		--failed-first \
		--durations=0 \
		--keep-baked-projects \
		$(CURDIR)/tests/test_build_run_image.py
		
# VERSION BUMP -------------------------------------------------------------------------------

.PHONY: version-patch version-minor version-major
version-patch version-minor version-major: ## commits version as patch (bug fixes not affecting the API), minor/minor (backwards-compatible/INcompatible API addition or changes)
	# upgrades as $(subst version-,,$@) version, commits and tags
	@bump2version --verbose  --list $(subst version-,,$@)


# TOOLS  -----------------------------------

.PHONY: info
info: ## displays info about the scope
	# python
	@which python
	@python --version
	@which pip
	@pip --version
	@pip list
	@cookiecutter --version
	# environs
	@echo "VERSION   : $(VERSION)"
	@echo "OUTPUT_DIR: $(OUTPUT_DIR)"
	@echo "TEMPLATE: $(CURDIR)"
	# cookiecutter config
	@jq '.' cookiecutter.json

.PHONY: clean clean-force

_git_clean_args = -dx --force --exclude=.vscode/ --exclude=.venv/ --exclude=.python --exclude="*keep*"

clean: ## cleans all unversioned files in project and temp files create by this makefile
	# Cleaning unversioned
	@git clean -n $(_git_clean_args)
	@echo -n "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo -n "$(shell whoami), are you REALLY sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	@git clean $(_git_clean_args)
	-rm -r --force $(OUTPUT_DIR)

clean-force: clean
	# removing .venv
	-@rm -r --force .venv

.PHONY: help
help: ## this colorful help
	@echo "Recipes for '$(notdir $(CURDIR))':"
	@echo ""
	@awk --posix 'BEGIN {FS = ":.*?## "} /^[[:alpha:][:space:]_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
