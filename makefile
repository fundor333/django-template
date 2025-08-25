SHELL := /bin/bash


.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: install
install: ## Make venv and install requirements
	@uv sync
	@uv run --env-file=.env  pre-commit install
	@pre-commit autoupdate

migrate: ## Make and run migrations
	@uv run --env-file=.env  python manage.py makemigrations
	@uv run --env-file=.env  python manage.py migrate
	@uv run --env-file=.env  python manage.py collectstatic --noinput

.PHONY: test
test: ## Run tests
	@uv run --env-file=.env  skjold -v audit uv.lock
	@uv run --env-file=.env  python manage.py test --verbosity=0 --parallel --failfast

.PHONY: run
run: ## Run the Django server
	@uv run --env-file=.env  python manage.py runserver

start: install migrate run ## Install requirements, apply migrations, then start development server

precommit: ## Run pre-commit hooks
	@git add . & uv run --env-file=.env pre-commit run --all-files

deploy: ## make the deploy code
	@uv export --no-hashes --format requirements-txt > requirements.txt
