<div align="center">

<h1>Frappe Dev Container Template</h1>

_Um ambiente pronto para desenvolver apps Frappe com VS Code, Docker, MariaDB e Redis._

![Frappe](https://img.shields.io/badge/Frappe-version--16-5e64ff?style=flat-square)
![Dev Containers](https://img.shields.io/badge/Dev%20Containers-ready-blue?style=flat-square&logo=visualstudiocode)
![Docker](https://img.shields.io/badge/Docker-required-2496ed?style=flat-square&logo=docker&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-11.8-003545?style=flat-square&logo=mariadb&logoColor=white)

[Visão geral](#visão-geral) • [Comece rápido](#comece-rápido) • [Comandos](#comandos) • [Configuração](#configuração) • [Troubleshooting](#troubleshooting)

[English](./README.md)

</div>

Este repositório é um template mínimo para iniciar projetos [Frappe Framework](https://frappeframework.com/) em um ambiente isolado e reproduzível usando [Dev Containers](https://containers.dev/).

Ele inclui uma stack local com `frappe/bench`, MariaDB e Redis, além de um `Makefile` pequeno para automatizar apenas o setup que seria repetitivo fazer direto com `bench`: inicializar a bench, configurar os serviços do compose, criar o site e instalar apps iniciais.

> [!NOTE]
> Este template é voltado para desenvolvimento local. Senhas, portas e serviços foram definidos para conveniência, não para produção.

## Visão geral

O template entrega:

- Ambiente Frappe baseado na imagem `frappe/bench:latest`.
- MariaDB `11.8` configurado para `utf8mb4`.
- Serviços Redis separados para cache e fila.
- Portas encaminhadas para o servidor web e assets em desenvolvimento.
- Extensões recomendadas do VS Code para Python, SQL, Vue, Prettier e Ruff.
- Automação via `make` apenas para o bootstrap inicial da bench local.
- Exemplos opcionais comentados para Mailpit e Cypress.

## Estrutura

```text
.
├── .devcontainer/
│   ├── devcontainer.json      # Configuração do VS Code Dev Containers
│   └── docker-compose.yml     # Serviços Frappe, MariaDB e Redis
└── Makefile                   # Bootstrap da bench e do site local
```

Após o bootstrap, a bench será criada em `frappe-bench`.

## Pré-requisitos

- [Docker](https://www.docker.com/get-started/)
- [VS Code](https://code.visualstudio.com/)
- Extensão [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- Git, se você pretende clonar apps privados ou trabalhar com repositórios externos

> [!TIP]
> O `devcontainer.json` monta automaticamente sua pasta `~/.ssh` dentro do container em `/home/frappe/.ssh`, facilitando o uso de repositórios privados.

## Comece rápido

1. Abra este repositório no VS Code.
2. Execute **Dev Containers: Reopen in Container** pela Command Palette.
3. Aguarde o container iniciar e instalar o `pre-commit` via `uv`.
4. No terminal do VS Code, rode:

```bash
make bootstrap
cd frappe-bench
bench start
```

5. Acesse [`http://dev.localhost:8000`](http://dev.localhost:8000).

Credenciais padrão:

| Usuário | Senha |
| --- | --- |
| `Administrator` | `admin` |

## Instalando apps

Você pode instalar apps junto com o bootstrap:

```bash
make bootstrap APPS="erpnext hrms"
```

Ou baixar e instalar apps depois:

```bash
cd frappe-bench
bench get-app erpnext --branch version-16
bench --site dev.localhost install-app erpnext
bench --site dev.localhost migrate
```

Para criar um app novo dentro da bench:

```bash
cd frappe-bench
bench new-app meu_app
bench --site dev.localhost install-app meu_app
```

## Comandos

Rode `make` ou `make help` para ver a ajuda gerada pelo próprio `Makefile`.

| Comando | Descrição |
| --- | --- |
| `make bootstrap` | Inicializa a bench, cria o site e instala apps definidos em `APPS`. |
| `make init` | Cria `frappe-bench` e configura MariaDB/Redis do Docker Compose. |
| `make new-site` | Cria o site padrão e ativa `developer_mode`. |

Depois disso, use `bench` diretamente dentro de `frappe-bench`:

```bash
cd frappe-bench
bench start
bench --site dev.localhost migrate
bench build
bench --site dev.localhost console
bench --site dev.localhost run-tests --app meu_app
```

## Configuração

Todas as variáveis principais podem ser sobrescritas na linha de comando:

| Variável | Padrão | Uso |
| --- | --- | --- |
| `BENCH` | `frappe-bench` | Nome da pasta da bench. |
| `SITE` | `dev.localhost` | Site usado pelos comandos de setup. |
| `FRAPPE_BRANCH` | `version-16` | Branch do Frappe usada no `bench init` e no bootstrap de apps. |
| `APPS` | vazio | Apps instalados pelo `make bootstrap`. |
| `ADMIN_PASSWORD` | `admin` | Senha do usuário `Administrator`. |
| `DB_ROOT_PASSWORD` | `123` | Senha root do MariaDB do container. |
| `DB_HOST` | `mariadb` | Host do serviço MariaDB no Docker Compose. |
| `REDIS_CACHE` | `redis://redis-cache:6379` | URL do Redis de cache. |
| `REDIS_QUEUE` | `redis://redis-queue:6379` | URL do Redis de fila e socket.io. |

Exemplos:

```bash
make bootstrap SITE=loja.localhost ADMIN_PASSWORD=secret APPS="erpnext"
cd frappe-bench
bench --site loja.localhost migrate
```

## Serviços

| Serviço | Imagem | Função |
| --- | --- | --- |
| `frappe` | `frappe/bench:latest` | Container principal de desenvolvimento. |
| `mariadb` | `mariadb:11.8` | Banco de dados local. |
| `redis-cache` | `redis:alpine` | Cache do Frappe. |
| `redis-queue` | `redis:alpine` | Filas e socket.io. |

Portas disponíveis:

| Porta | Uso comum |
| --- | --- |
| `8000-8005` | Servidor web Frappe. |
| `9000-9005` | Assets/watchers em desenvolvimento. |
| `6787` | Porta encaminhada pelo Dev Container para ferramentas auxiliares. |

## Recursos opcionais

O `docker-compose.yml` já traz exemplos comentados para habilitar serviços extras:

- **Mailpit**: útil para testar envio de emails localmente.
- **Cypress UI**: útil para executar testes end-to-end com interface gráfica.

Para usar esses serviços, descomente os blocos correspondentes no `.devcontainer/docker-compose.yml` e reconstrua o container.

## Troubleshooting

> [!WARNING]
> `bench drop-site` é destrutivo. Confira o site e os backups antes de remover qualquer ambiente local.

### O site não abre no navegador

Verifique se `bench start` está rodando dentro de `frappe-bench` e se o Frappe iniciou na porta `8000`. Para outro site, use o domínio definido em `SITE`, por exemplo `http://loja.localhost:8000`.

### Erro de conexão com MariaDB

Confirme que o comando foi executado dentro do Dev Container. O host do banco é `mariadb`, não `localhost`, porque ele aponta para o serviço do Docker Compose.

### Quero refazer o ambiente do zero

Use `bench drop-site <site>` dentro de `frappe-bench` para remover apenas o site, ou remova a pasta `frappe-bench` e recrie com `make bootstrap`. Os dados do MariaDB ficam no volume Docker `mariadb-data`.

### Apps privados não clonam

Confirme que sua chave SSH existe no host em `~/.ssh` e reconstrua o container depois de mudanças relevantes na configuração do Dev Container.

## Recursos

- [Frappe Framework](https://frappeframework.com/)
- [Frappe Bench](https://frappeframework.com/docs/user/en/bench)
- [Dev Containers](https://containers.dev/)
- [MariaDB](https://mariadb.org/)
- [Redis](https://redis.io/)
