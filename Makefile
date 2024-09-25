DOCKER-RUN = docker compose run -e TERM -e DISABLE_SPRING_WATCHER_LISTEN=1 --rm --entrypoint=""
BUNDLE-EXEC = bundle exec

install: ## Setup development environment
	bin/setup

run: ## Start the application (web, jobs et webpack)
	foreman s -f Procfile.dev

lint: lint_rubocop lint_eslint ## Run all linters

lint_rubocop: ## Ruby linter
	bundle exec rubocop

lint_eslint: ## JavaScript Linter
	bundle exec eslint 'app/javascript/**' --quiet --fix

autocorrect: ## Fix autocorrectable lint issues
	bundle exec rubocop --auto-correct-all

test: ## Run all tests
	bundle exec rspec

clean: ## Clean temporary files (including weppacks) and logs
	bundle exec rails log:clear tmp:clear

help: ## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

rswag:
	SWAGGER_DRY_RUN=0 RAILS_ENV=test rake rswag:specs:swaggerize PATTERN="spec/requests/api/**/*_spec.rb"

sh: ## [docker] Runs a shell within the web container
	$(DOCKER-RUN) web bash

cl: ## [docker] Runs a Rails console within the web container
	$(DOCKER-RUN) web $(BUNDLE-EXEC) bin/rails c
