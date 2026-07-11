# Codex CLI (codex)

Instala o [Codex CLI](https://github.com/openai/codex), o agente de codificação de código aberto da OpenAI para desenvolvimento assistido por IA diretamente no terminal.

## Exemplo de uso

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/codex:1": {}
}
```

## Opções

| Opção           | Tipo   | Padrão   | Descrição                                                                                                                        |
| --------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `version`       | string | `latest` | Versão do Codex CLI a instalar: `latest` ou uma versão específica (ex.: `0.144.1`).                                             |
| `installMethod` | string | `auto`   | Método de instalação: `auto` (npm com fallback para o binário nativo), `npm` (npm global) ou `native` (binário das releases).   |

## Métodos de instalação

- **`auto`** (padrão): usa `npm install -g @openai/codex` quando o `npm` está disponível; caso contrário, recorre ao binário nativo das releases do GitHub.
- **`npm`**: força a instalação via npm global. Requer Node.js — combine com a feature [`node`](https://github.com/devcontainers/features/tree/main/src/node).
- **`native`**: força o download do binário oficial das [releases do GitHub](https://github.com/openai/codex/releases) (build `musl`), colocado em `~/.local/bin` do usuário remoto. Não requer Node.js.

## Exemplos

### Com Node.js (via npm)

```jsonc
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/raferreira96/devcontainers/codex:1": {
        "installMethod": "npm"
    }
}
```

### Sem Node.js (binário nativo)

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/codex:1": {
        "installMethod": "native",
        "version": "0.144.1"
    }
}
```

## Notas

- O script de instalação roda como `root` e detecta o usuário remoto via `_REMOTE_USER`, instalando o binário nativo no diretório do usuário correto.
- O método `native` detecta a arquitetura (`x86_64` e `aarch64`) e baixa o build `musl` correspondente; para uma versão específica, aceita `0.144.1`, `v0.144.1` ou o formato completo `rust-v0.144.1`.
- A feature declara `installsAfter` para `common-utils` e `node`, garantindo que sejam instaladas antes quando presentes.
- O diretório `~/.local/bin` do usuário é adicionado ao `PATH` via `containerEnv`.
- Suporta distribuições baseadas em `apt`, `apk`, `dnf` e `yum` para dependências como `curl`, `tar` e `gzip`.

## Uso

Após a criação do container, autentique-se e execute:

```bash
codex
```

Consulte a [documentação oficial](https://github.com/openai/codex) para autenticação e configuração.
