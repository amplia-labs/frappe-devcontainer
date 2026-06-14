# Makefile for the Frappe devcontainer.
# Run inside the container from the VS Code terminal.
#
# Everything is driven by overridable variables, for example:
#   make new-site SITE=store.localhost
#   make bootstrap APPS="erpnext hrms"
#
# `make` without arguments shows help.

# ----------------------------------------------------------------------------
# Variables (all can be overridden on the command line: make <target> VAR=value)
# ----------------------------------------------------------------------------
BENCH            ?= frappe-bench
SITE             ?= dev.localhost
FRAPPE_BRANCH    ?= version-16
APPS             ?=
ADMIN_PASSWORD   ?= admin
DB_ROOT_PASSWORD ?= 123

# Service hosts, as defined in the devcontainer docker-compose.yml.
DB_HOST          ?= mariadb
REDIS_CACHE      ?= redis://redis-cache:6379
REDIS_QUEUE      ?= redis://redis-queue:6379

.DEFAULT_GOAL := help

# ----------------------------------------------------------------------------
# Setup
# ----------------------------------------------------------------------------
.PHONY: bootstrap
bootstrap: init new-site ## From scratch to a running site: init + new-site + install APPS
	@cd $(BENCH) && for app in $(APPS); do \
		echo ">> Adding app '$$app'..."; \
		bench get-app "$$app" --branch $(FRAPPE_BRANCH) && \
		bench --site $(SITE) install-app "$$app" || exit 1; \
	done
	@echo ">> Ready. Run 'cd $(BENCH) && bench start' and open http://$(SITE):8000 (Administrator / $(ADMIN_PASSWORD))"

.PHONY: init
init: ## Initialize the bench idempotently and point it to compose services
	@if [ -d "$(BENCH)" ]; then \
		echo ">> '$(BENCH)/' already exists, skipping bench init"; \
	else \
		echo ">> Initializing bench (frappe $(FRAPPE_BRANCH))..."; \
		bench init --skip-redis-config-generation --frappe-branch $(FRAPPE_BRANCH) $(BENCH); \
		cd $(BENCH) && \
		bench set-config -g db_host $(DB_HOST) && \
		bench set-config -g redis_cache $(REDIS_CACHE) && \
		bench set-config -g redis_queue $(REDIS_QUEUE) && \
		bench set-config -g redis_socketio $(REDIS_QUEUE); \
	fi

.PHONY: new-site
new-site: ## Create SITE if needed and set it as the default site
	@if [ -d "$(BENCH)/sites/$(SITE)" ]; then \
		echo ">> Site '$(SITE)' already exists, skipping"; \
	else \
		echo ">> Creating site '$(SITE)'..."; \
		cd $(BENCH) && bench new-site $(SITE) \
			--no-mariadb-socket \
			--mariadb-root-password $(DB_ROOT_PASSWORD) \
			--admin-password $(ADMIN_PASSWORD) && \
		bench use $(SITE) && \
		bench --site $(SITE) set-config developer_mode 1; \
	fi

# ----------------------------------------------------------------------------
# Help (auto-generated from the '## ' comments above)
# ----------------------------------------------------------------------------
.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*## "; \
		printf "\nUsage: make \033[36m<target>\033[0m [VAR=value]\n\nTargets:\n"} \
		/^[a-zA-Z0-9_-]+:.*## / {printf "  \033[36m%-13s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\nVariables (default): SITE=$(SITE)  FRAPPE_BRANCH=$(FRAPPE_BRANCH)  BENCH=$(BENCH)  APPS=\"$(APPS)\"\n\n"
