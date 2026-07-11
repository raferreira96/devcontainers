# Dev Containers

Coleção de artefatos [Dev Container](https://containers.dev) publicados no GHCR
sob o namespace **`raferreira96`**: **Features** (instaláveis em qualquer Dev
Container) e **Imagens** (bases prontas para uso).

## Features

Componentes que adicionam ferramentas a um Dev Container existente, referenciados
no campo `features` do `devcontainer.json`.

| Feature | Descrição |
| ------- | --------- |
| [`claude-code`](src/features/claude-code/) | Instala o [Claude Code](https://docs.anthropic.com/claude-code), a CLI oficial da Anthropic, via npm global ou instalador nativo. |
| [`codex`](src/features/codex/) | Instala o [Codex CLI](https://github.com/openai/codex), o agente de codificação de código aberto da OpenAI, via npm global ou binário nativo. |
| [`antigravity`](src/features/antigravity/) | Instala o [Antigravity CLI](https://antigravity.google/docs/cli) (`agy`), o agente de codificação da Google para o terminal, via instalador nativo oficial. |
| [`opencode`](src/features/opencode/) | Instala o [OpenCode](https://opencode.ai/docs), o agente de codificação de código aberto para o terminal, via npm global ou instalador nativo. |
| [`pi`](src/features/pi/) | Instala o [Pi](https://pi.dev/docs), o agente de codificação de código aberto (BYOK) para o terminal, via npm global ou instalador nativo. |

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/claude-code:1": {}
}
```

## Imagens

Imagens Docker prontas para serem usadas como base de um Dev Container, referenciadas
no campo `image` do `devcontainer.json`.

| Imagem | Descrição |
| ------ | --------- |
| [`node`](src/images/node/) | Baseada na imagem oficial do Node.js (bookworm) com **npm**, **Yarn** e **pnpm** prontos para uso e usuário não-root `node`. |

```jsonc
{
    "image": "ghcr.io/raferreira96/devcontainers/node:latest",
    "remoteUser": "node"
}
```

## Estrutura do repositório

```
src/
├── features/<id>/     # devcontainer-feature.json + install.sh
└── images/<id>/       # .devcontainer/ (Dockerfile + devcontainer.json) + README.md
test/
└── features/<id>/     # test.sh + scenarios.json (dev-container-features-test-lib)
.github/workflows/
├── test.yaml          # testa as features em PRs e na main
├── release.yaml       # publica as features no GHCR
└── publish-images.yaml # build multi-arquitetura e push das imagens no GHCR
```

## Desenvolvimento

Testar as features localmente (requer o [Dev Container CLI](https://github.com/devcontainers/cli)):

```bash
npm install -g @devcontainers/cli
devcontainer features test --features claude-code .
```

Construir uma imagem localmente:

```bash
docker build -t node-dev src/images/node/.devcontainer
```

## Publicação

A publicação no GHCR é automática ao integrar na branch `main`:

- **Features** → `release.yaml` (via `devcontainers/action`).
- **Imagens** → `publish-images.yaml` (via `docker buildx`, `linux/amd64` e `linux/arm64`).

## Licença

MIT.
