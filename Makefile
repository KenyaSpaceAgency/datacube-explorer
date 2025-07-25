.DEFAULT_GOAL := help

help: ## Display this help text
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install all requirements and explorer
	pip install -U setuptools pip
	pip install -e .[test]

.PHONY: format
format: ## Reformat all Python code
	ruff format cubedash integration_tests ./*.py

.PHONY: lint
lint: ## Run all Python linting checks
	git config --global --add safe.directory /code
	python3 setup.py check -ms
	pre-commit run -a

.PHONY: weblint
weblint: ## Run stylelint across HTML and SASS
	stylelint $(find . -iname '*.html') $(find . -iname '*.sass')


static: style js

.PHONY: style
style: cubedash/static/base.css ## Compile SASS stylesheets to CSS

cubedash/static/base.css: cubedash/static/base.sass
	npx sass $< $@

node_modules:
	npm install @types/geojson @types/leaflet

.PHONY: js ## Compile Typescript to JS
js: cubedash/static/overview.js node_modules

cubedash/static/overview.js: cubedash/static/overview.ts
	tsc --build cubedash/static/tsconfig.json

.PHONY: test
test: ## Run tests using pytest
	pytest --cov=cubedash --cov-report=xml -r sx --durations=5

.PHONY: testcov
testcov:
	pytest --cov=cubedash
	@echo "building coverage html"
	@coverage html

.PHONY: clean
clean:  ## Clean all working/temporary files
	rm -rf `find . -name __pycache__`
	rm -f `find . -type f -name '*.py[co]' `
	rm -f `find . -type f -name '*~' `
	rm -f `find . -type f -name '.*~' `
	rm -rf .cache
	rm -rf .pytest_cache
	rm -rf .mypy_cache
	rm -rf htmlcov
	rm -rf *.egg-info
	rm -f .coverage
	rm -f .coverage.*
	rm -rf build
	# python setup.py clean

.PHONY: up build schema index

# DOCKER STUFF
up: ## Start server using Docker
	docker compose up --quiet-pull

up-d: ## Start server using Docker in background
	docker compose up -d --quiet-pull

build: ## Build the dev Docker image
	docker compose build

docker-clean: ## Get rid of the local docker env and DB
	docker compose down

build-prod: ## Build the prod Docker image
	docker compose \
		--file docker-compose.yml \
		build

up-prod: ## Start using the prod Docker image
	docker compose \
		--file docker-compose.yml \
		up -d --wait --quiet-pull

init-odc: ## Initialise ODC Database
	docker compose exec -T explorer \
		datacube system init

docker-shell: ## Get a shell into local Docker environ
	docker compose exec -T explorer \
		bash

schema: ## Initialise Explorer DB using Docker
	docker compose exec -T explorer \
		cubedash-gen -v --init

index: ## Update Explorer DB using Docker
	docker compose exec -T explorer \
		cubedash-gen --all

force-refresh: ## Entirely refresh the Explorer tables in Docker
	docker compose exec -T explorer \
		cubedash-gen --force-refresh --refresh-stats --all

create-test-db-docker: ## Create a test database inside Docker
	docker compose run --rm -T explorer \
		bash /code/.docker/create_db.sh

lint-docker: ## Run linting inside inside Docker
	docker compose run --rm explorer \
		make lint

test-docker: ## Run tests inside Docker
	docker compose run --rm explorer \
		pytest --cov=cubedash --cov-report=xml -r sx --durations=5
