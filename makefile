SHELL := /bin/bash

include .env

.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: env
env:  ## Install pipenv
	pipenv shell --python 3.9

.PHONY: install
install: env ## Make venv and install requirements
	pipenv install --development
	pipenv run pre-commit install
	pre-commit autoupdate

migrate: ## Make and run migrations
	pipenv run manage.py makemigrations
	pipenv run manage.py migrate

.PHONY: test
test: ## Run tests
	pipenv run skjold -v audit Pipenv.lock
	pipenv run python manage.py test application --verbosity=0 --parallel --failfast

.PHONY: run
run: ## Run the Django server
	pipenv run python manage.py runserver

start: install migrate run ## Install requirements, apply migrations, then start development server

.PHONY: check
check: ## Run checks on the packages
	pipenv run skjold -v audit Pipenv.lock
