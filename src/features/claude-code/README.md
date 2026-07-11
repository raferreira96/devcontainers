# Claude Code (claude-code)

Instala o [Claude Code](https://docs.anthropic.com/claude-code), a CLI oficial da Anthropic para desenvolvimento assistido por IA diretamente no terminal.

## Exemplo de uso

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/claude-code:1": {}
}
```

## Opções

| Opção           | Tipo   | Padrão   | Descrição                                                                                                                             |
| --------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `version`       | string | `latest` | Versão do Claude Code a instalar: `latest`, `stable` ou uma versão específica (ex.: `1.0.0`).                                        |
| `installMethod` | string | `auto`   | Método de instalação: `auto` (npm com fallback para o instalador nativo), `npm` (npm global) ou `native` (instalador oficial).      |

## Métodos de instalação

- **`auto`** (padrão): usa `npm install -g @anthropic-ai/claude-code` quando o `npm` está disponível; caso contrário, recorre ao instalador oficial da Anthropic.
- **`npm`**: força a instalação via npm global. Requer Node.js — combine com a feature [`node`](https://github.com/devcontainers/features/tree/main/src/node).
- **`native`**: força o instalador oficial (`https://claude.ai/install.sh`), que coloca o binário em `~/.local/bin` do usuário remoto. Não requer Node.js.

## Exemplos

### Com Node.js (via npm)

```jsonc
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/raferreira96/devcontainers/claude-code:1": {
        "installMethod": "npm"
    }
}
```

### Sem Node.js (instalador nativo)

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/claude-code:1": {
        "installMethod": "native",
        "version": "stable"
    }
}
```

## Notas

- O script de instalação roda como `root` e detecta o usuário remoto via `_REMOTE_USER`, instalando o binário nativo no diretório do usuário correto.
- A feature declara `installsAfter` para `common-utils` e `node`, garantindo que sejam instaladas antes quando presentes.
- O diretório `~/.local/bin` do usuário é adicionado ao `PATH` via `containerEnv`.
- Suporta distribuições baseadas em `apt`, `apk`, `dnf` e `yum` para dependências como `curl`.

## Uso

Após a criação do container, autentique-se e execute:

```bash
claude
```

Consulte a [documentação oficial](https://docs.anthropic.com/claude-code) para autenticação e configuração.
