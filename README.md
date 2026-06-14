<div align="center">

<h1>Frappe Dev Container Template</h1>

_A ready-to-use environment for building Frappe apps with VS Code, Docker, MariaDB, and Redis._

![Frappe](https://img.shields.io/badge/Frappe-version--16-5e64ff?style=flat-square)
![Dev Containers](https://img.shields.io/badge/Dev%20Containers-ready-blue?style=flat-square&logo=visualstudiocode)
![Docker](https://img.shields.io/badge/Docker-required-2496ed?style=flat-square&logo=docker&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-11.8-003545?style=flat-square&logo=mariadb&logoColor=white)

[Overview](#overview) • [Quickstart](#quickstart) • [Commands](#commands) • [Configuration](#configuration) • [Troubleshooting](#troubleshooting)

[Português do Brasil](./README.pt-BR.md)

</div>

This repository is a minimal template for starting [Frappe Framework](https://frappeframework.com/) projects in an isolated and reproducible [Dev Containers](https://containers.dev/) environment.

It includes a local stack with `frappe/bench`, MariaDB, and Redis, plus a small `Makefile` that automates only the setup steps that are repetitive to do directly with `bench`: initialize the bench, configure compose services, create the site, and install initial apps.

> [!NOTE]
> This template is intended for local development. Passwords, ports, and services are configured for convenience, not production.

## Overview

This template provides:

- Frappe environment based on the `frappe/bench:latest` image.
- MariaDB `11.8` configured with `utf8mb4`.
- Separate Redis services for cache and queue.
- Forwarded ports for the web server and development assets.
- Recommended VS Code extensions for Python, SQL, Vue, Prettier, and Ruff.
- OpenCode and Claude Code installed inside the Dev Container.
- `make` automation only for the initial local bench bootstrap.
- Optional commented examples for Mailpit and Cypress.

## Structure

```text
.
├── .devcontainer/
│   ├── devcontainer.json      # VS Code Dev Containers configuration
│   └── docker-compose.yml     # Frappe, MariaDB, and Redis services
└── Makefile                   # Local bench and site bootstrap
```

After bootstrapping, the bench is created at `frappe-bench`.

## Prerequisites

- [Docker](https://www.docker.com/get-started/)
- [VS Code](https://code.visualstudio.com/)
- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
- Git, if you plan to clone private apps or work with external repositories

> [!TIP]
> `devcontainer.json` automatically mounts your host `~/.ssh` directory into `/home/frappe/.ssh` inside the container, making private repository access easier.

## Quickstart

1. Open this repository in VS Code.
2. Run **Dev Containers: Reopen in Container** from the Command Palette.
3. Wait for the container to start and install `pre-commit`, OpenCode, and Claude Code.
4. In the VS Code terminal, run:

```bash
make bootstrap
cd frappe-bench
bench start
```

5. Open [`http://dev.localhost:8000`](http://dev.localhost:8000).

Default credentials:

| User | Password |
| --- | --- |
| `Administrator` | `admin` |

## Installing Apps

Install apps during bootstrap:

```bash
make bootstrap APPS="erpnext hrms"
```

Or fetch and install apps later:

```bash
cd frappe-bench
bench get-app erpnext --branch version-16
bench --site dev.localhost install-app erpnext
bench --site dev.localhost migrate
```

To create a new app inside the bench:

```bash
cd frappe-bench
bench new-app my_app
bench --site dev.localhost install-app my_app
```

## Commands

Run `make` or `make help` to see the generated help from the `Makefile`.

| Command | Description |
| --- | --- |
| `make bootstrap` | Initializes the bench, creates the site, and installs apps from `APPS`. |
| `make init` | Creates `frappe-bench` and configures MariaDB/Redis from Docker Compose. |
| `make new-site` | Creates the default site and enables `developer_mode`. |

After that, use `bench` directly inside `frappe-bench`:

```bash
cd frappe-bench
bench start
bench --site dev.localhost migrate
bench build
bench --site dev.localhost console
bench --site dev.localhost run-tests --app my_app
```

## Configuration

All main variables can be overridden from the command line:

| Variable | Default | Usage |
| --- | --- | --- |
| `BENCH` | `frappe-bench` | Bench directory name. |
| `SITE` | `dev.localhost` | Site used by setup commands. |
| `FRAPPE_BRANCH` | `version-16` | Frappe branch used by `bench init` and app bootstrap. |
| `APPS` | empty | Apps installed by `make bootstrap`. |
| `ADMIN_PASSWORD` | `admin` | `Administrator` user password. |
| `DB_ROOT_PASSWORD` | `123` | Container MariaDB root password. |
| `DB_HOST` | `mariadb` | MariaDB service host from Docker Compose. |
| `REDIS_CACHE` | `redis://redis-cache:6379` | Redis cache URL. |
| `REDIS_QUEUE` | `redis://redis-queue:6379` | Redis queue and socket.io URL. |

Examples:

```bash
make bootstrap SITE=store.localhost ADMIN_PASSWORD=secret APPS="erpnext"
cd frappe-bench
bench --site store.localhost migrate
```

## Services

| Service | Image | Purpose |
| --- | --- | --- |
| `frappe` | `frappe/bench:latest` | Main development container. |
| `mariadb` | `mariadb:11.8` | Local database. |
| `redis-cache` | `redis:alpine` | Frappe cache. |
| `redis-queue` | `redis:alpine` | Queues and socket.io. |

Available ports:

| Port | Common use |
| --- | --- |
| `8000-8005` | Frappe web server. |
| `9000-9005` | Development assets/watchers. |
| `6787` | Dev Container forwarded port for auxiliary tools. |

## AI Coding Agents

Claude Code and OpenCode are installed during `postCreateCommand` using their official native installers. Both are available in the Dev Container terminal:

```bash
opencode
claude
```

The Dev Container uses Docker volumes for agent configuration and sessions, so they survive container rebuilds without reusing host agent state:

| Volume | Container path | Purpose |
| --- | --- | --- |
| `frappe-devcontainer-claude` | `/home/frappe/.claude` | Claude Code settings, agents, commands, backups, and persisted state. |
| `frappe-devcontainer-opencode` | `/home/frappe/.opencode` | OpenCode binary, configuration, authentication, session, state, and cache data. |

Claude Code uses `CLAUDE_CONFIG_DIR=/home/frappe/.claude`, matching the volume-backed setup used by common Claude Code Dev Container examples. OpenCode uses a wrapper that points all of its XDG directories (config/data/state/cache) under `/home/frappe/.opencode`, so everything lives in a single volume without replacing `/home/frappe/.local` and the tools provided by the base image remain available. Because these volumes are created empty and owned by `root`, `post-create.sh` reassigns them to the `frappe` user before installing the agents.

Run each tool once inside the container to authenticate or configure providers.

## Optional Services

The `docker-compose.yml` file includes commented examples for additional services:

- **Mailpit**: useful for testing outgoing email locally.
- **Cypress UI**: useful for running end-to-end tests with a graphical interface.

To use these services, uncomment the relevant blocks in `.devcontainer/docker-compose.yml` and rebuild the container.

## Troubleshooting

> [!WARNING]
> `bench drop-site` is destructive. Check the site name and backups before removing any local environment.

### The site does not open in the browser

Make sure `bench start` is running inside `frappe-bench` and that Frappe started on port `8000`. For a custom site, use the domain configured in `SITE`, for example `http://store.localhost:8000`.

### MariaDB connection error

Make sure the command is running inside the Dev Container. The database host is `mariadb`, not `localhost`, because it points to the Docker Compose service.

### I want to recreate the environment from scratch

Use `bench drop-site <site>` inside `frappe-bench` to remove only the site, or remove the `frappe-bench` directory and recreate it with `make bootstrap`. MariaDB data is stored in the Docker volume `mariadb-data`.

### Private apps do not clone

Make sure your SSH key exists on the host at `~/.ssh` and rebuild the container after relevant Dev Container configuration changes.

## Resources

- [Frappe Framework](https://frappeframework.com/)
- [Frappe Bench](https://frappeframework.com/docs/user/en/bench)
- [Dev Containers](https://containers.dev/)
- [MariaDB](https://mariadb.org/)
- [Redis](https://redis.io/)
