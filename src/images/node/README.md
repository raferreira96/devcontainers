# Imagem Dev Container — Node.js

Imagem de desenvolvimento baseada na [imagem oficial do Node.js](https://hub.docker.com/_/node)
(Debian *bookworm*), já com os três principais gerenciadores de pacotes prontos
para uso: **npm**, **Yarn** e **pnpm**.

Publicada no GHCR:

```
ghcr.io/raferreira96/devcontainers/node:latest
```

## O que vem na imagem

| Ferramenta | Origem | Observação |
| ---------- | ------ | ---------- |
| **Node.js** | imagem oficial `node` | LTS 22 por padrão |
| **npm** | incluído no Node | atualizado com o Node |
| **Yarn** | [Corepack](https://nodejs.org/api/corepack.html) | *stable* (Berry 4.x) |
| **pnpm** | Corepack | *latest* |
| git, curl, ssh, less, procps | apt | utilitários comuns de dev |

O Corepack (que acompanha o Node) gerencia Yarn e pnpm a partir de um cache
compartilhado (`COREPACK_HOME`), então os gerenciadores ficam disponíveis para o
usuário não-root **sem downloads em tempo de execução**.

## Boas práticas aplicadas

- **Baseada na imagem oficial do Node**, evitando reinventar o runtime.
- **Usuário não-root `node`** (UID/GID 1000) como padrão — princípio do menor privilégio.
- **Camadas enxutas**: uma única camada de `apt` com limpeza do cache (`rm -rf /var/lib/apt/lists/*`).
- **Versão parametrizável** via `ARG VARIANT` (ex.: `20-bookworm`, `22-bookworm`).
- **`pnpm add -g` sem `sudo`**: `PNPM_HOME` configurado e adicionado ao `PATH`,
  inclusive em *login shells* (via `/etc/profile.d`), que é como o terminal do
  VS Code inicia.
- **Rótulos OCI** (`org.opencontainers.image.*`) para rastreabilidade no GHCR.

## Como usar

### 1. Referenciando a imagem publicada

No `devcontainer.json` do seu projeto:

```jsonc
{
  "name": "Meu projeto Node",
  "image": "ghcr.io/raferreira96/devcontainers/node:latest",
  "remoteUser": "node"
}
```

### 2. Construindo a partir do Dockerfile

A pasta [`.devcontainer/`](.devcontainer/) traz um `devcontainer.json` de exemplo
que constrói a imagem localmente. Basta abrir esta pasta no VS Code e executar
**Dev Containers: Reopen in Container**.

Para trocar a versão do Node no build:

```bash
docker build --build-arg VARIANT=20-bookworm -t node-dev .devcontainer
```

## Verificação rápida

```bash
node -v   # v22.x
npm -v
yarn -v   # 4.x (Berry)
pnpm -v   # 11.x
```
