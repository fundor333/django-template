SHELL := /bin/bash

include .env

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Make venv and install requirements
	$(BIN) pipenv install; pipenv run pre-commit install

migrate: ## Make and run migrations
	$(PYTHON) manage.py makemigrations
	$(PYTHON) manage.py migrate

.PHONY: test
test: ## Run tests
	$(PYTHON) $(APP_DIR)/manage.py test application --verbosity=0 --parallel --failfast

.PHONY: run
run: ## Run the Django server
	$(PYTHON) $(APP_DIR)/manage.py runserver

start: install migrate run ## Install requirements, apply migrations, then start development server
