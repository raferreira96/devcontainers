# Node.js + PostGIS + Redis + MinIO (com CLIs de IA)

Template de Dev Container para desenvolvimento **Node.js** com um _stack_ de dados
completo — **PostgreSQL/PostGIS**, **Redis** e **MinIO** — orquestrado via **Docker
Compose**. O container de desenvolvimento usa a [imagem Node do próprio
repositório](https://github.com/raferreira96/devcontainers/tree/main/src/images/node)
(`ghcr.io/raferreira96/devcontainers/node`) e já traz **todas as CLIs de IA** da
coleção, com as **configurações dos agentes persistidas a partir do host**.

## O que vem no ambiente

| Componente | Origem | Acesso |
| ---------- | ------ | ------ |
| **Node.js** (npm, Yarn, pnpm) | `ghcr.io/raferreira96/devcontainers/node` | container `app` |
| **PostgreSQL + PostGIS** | `postgis/postgis` | serviço `db` (`db:5432`) |
| **Redis** | `redis:7-alpine` | serviço `redis` (`redis:6379`) |
| **MinIO** (S3) | `minio/minio` | serviço `minio` (`minio:9000`, console `minio:9001`) |
| **Claude Code** (`claude`) | feature `claude-code` | CLI de IA |
| **Codex CLI** (`codex`) | feature `codex` | CLI de IA |
| **OpenCode** (`opencode`) | feature `opencode` | CLI de IA |
| **Antigravity** (`agy`) | feature `antigravity` | CLI de IA |
| **Pi** (`pi`) | feature `pi` | CLI de IA |
| **RTK** (`rtk`) | feature `rtk` | proxy de economia de tokens |

## Opções do template

| Opção | Padrão | Descrição |
| ----- | ------ | --------- |
| `imageTag` | `latest` | Tag da imagem Node do repositório (`latest`, `22`, `20`). |
| `postgresVersion` | `17` | Versão maior do PostgreSQL/PostGIS (`postgis/postgis:<versão>-3.5`). |
| `postgresDb` | `app` | Nome do banco criado automaticamente. |

## Persistência das configurações dos agentes

O `devcontainer.json` monta os diretórios de configuração de cada agente **do host
para dentro do container**, de modo que autenticação, histórico e ajustes
sobrevivam a _rebuilds_ do container e sejam compartilhados com o host:

| Agente | Diretório no host | Alvo no container |
| ------ | ----------------- | ----------------- |
| Claude Code | `~/.claude` + `~/.claude.json` | `/home/node/.claude` (+ `.claude.json`) |
| Codex | `~/.codex` | `/home/node/.codex` |
| OpenCode | `~/.config/opencode` + `~/.local/share/opencode` | idem |
| Pi | `~/.pi` | `/home/node/.pi` |
| Antigravity | `~/.gemini` | `/home/node/.gemini` |
| RTK | `~/.config/rtk` + `~/.rtk` | idem |

Um `initializeCommand` cria esses caminhos no host **antes** de subir o container,
garantindo que os _bind mounts_ anexem a diretórios já existentes (evitando pastas
criadas como `root` pelo Docker) e que `~/.claude.json` seja montado como arquivo.

> **Observações**
> - O **Antigravity** guarda credenciais no _keyring_ do sistema operacional, não em
>   arquivo; portanto, o login em si **não** é persistido pelo bind mount (apenas
>   configurações e `GEMINI.md`). Será necessário refazer o _sign-in_ quando o
>   keyring do container for recriado.
> - Os _bind mounts_ assumem que o usuário do host tem **UID/GID 1000** (igual ao
>   usuário `node` da imagem). Em hosts com outro UID podem ocorrer problemas de
>   permissão nos arquivos montados.
> - Em **Windows**, rode o Docker via **WSL2** (o `initializeCommand` usa sintaxe de
>   shell POSIX) ou ajuste os caminhos manualmente.

## Como usar

### Aplicando o template

Pelo VS Code: **Dev Containers: New Dev Container...** → busque por
_"Node.js + PostGIS + Redis + MinIO"_.

Ou pela CLI:

```bash
devcontainer templates apply \
  -t ghcr.io/raferreira96/devcontainers/node-postgis-redis-minio:latest \
  --workspace-folder .
```

Em seguida, **Dev Containers: Reopen in Container**.

### Conectando aos serviços (de dentro do container)

O container `app` já expõe variáveis de ambiente prontas:

```bash
# PostgreSQL / PostGIS
psql "$DATABASE_URL" -c "CREATE EXTENSION IF NOT EXISTS postgis; SELECT postgis_full_version();"

# Redis
redis-cli -u "$REDIS_URL" ping   # PONG

# MinIO (API S3 em $S3_ENDPOINT; console em http://localhost:9001)
#   usuário/senha padrão: minioadmin / minioadmin
```

| Variável | Valor |
| -------- | ----- |
| `DATABASE_URL` | `postgresql://postgres:postgres@db:5432/app` |
| `REDIS_URL` | `redis://redis:6379` |
| `S3_ENDPOINT` / `AWS_ENDPOINT_URL_S3` | `http://minio:9000` |
| `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` | `minioadmin` / `minioadmin` |

> As credenciais são padrões **apenas para desenvolvimento local**. Não use este
> template como base para produção sem trocá-las.

### Usando as CLIs de IA

```bash
claude    # Claude Code (Anthropic)
codex     # Codex CLI (OpenAI)
opencode  # OpenCode
agy       # Antigravity (Google)
pi        # Pi (BYOK)
rtk gain  # analytics de economia de tokens do RTK
```

Como as configurações são montadas do host, se você já estiver autenticado nessas
ferramentas na sua máquina, o login normalmente já estará disponível no container
(exceto Antigravity — veja as observações acima).

## Testando localmente

Suba o ambiente e verifique as ferramentas:

```bash
devcontainer up --workspace-folder .
devcontainer exec --workspace-folder . node -v
devcontainer exec --workspace-folder . claude --version
```
