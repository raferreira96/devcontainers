# Pi Coding Agent (pi)

Instala o [Pi](https://pi.dev/docs), o agente de codificação de código aberto e _bring-your-own-key_ (BYOK) para desenvolvimento assistido por IA diretamente no terminal. O mesmo agente roda contra Claude, GPT, Gemini, Grok ou modelos locais.

## Exemplo de uso

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/pi:1": {}
}
```

## Opções

| Opção           | Tipo   | Padrão   | Descrição                                                                                                                     |
| --------------- | ------ | -------- | --------------------------------------------------------------------------------------------------------------------------- |
| `version`       | string | `latest` | Versão do Pi a instalar: `latest` ou uma versão específica (ex.: `0.74.0`). Aplicável ao método `npm`.                       |
| `installMethod` | string | `auto`   | Método de instalação: `auto` (npm com fallback para o instalador nativo), `npm` (npm global) ou `native` (instalador oficial). |

## Métodos de instalação

- **`auto`** (padrão): usa `npm install -g --ignore-scripts @earendil-works/pi-coding-agent` quando o `npm` está disponível; caso contrário, recorre ao instalador oficial do Pi.
- **`npm`**: força a instalação via npm global (pacote `@earendil-works/pi-coding-agent`, com `--ignore-scripts` conforme recomendado pela documentação). Requer Node.js — combine com a feature [`node`](https://github.com/devcontainers/features/tree/main/src/node).
- **`native`**: força o instalador oficial (`https://pi.dev/install.sh`), que instala no diretório global do npm ou em `~/.local` do usuário remoto e faz _bootstrap_ do Node.js quando ausente. Não requer Node.js previamente instalado.

## Exemplos

### Com Node.js (via npm)

```jsonc
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/raferreira96/devcontainers/pi:1": {
        "installMethod": "npm"
    }
}
```

### Sem Node.js (instalador nativo)

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/pi:1": {
        "installMethod": "native"
    }
}
```

## Notas

- O script de instalação roda como `root` e detecta o usuário remoto via `_REMOTE_USER`, instalando para o usuário correto.
- A opção `version` é aplicada ao método `npm`; o instalador nativo sempre instala a última versão.
- A feature declara `installsAfter` para `common-utils` e `node`, garantindo que sejam instaladas antes quando presentes.
- O diretório `~/.local/bin` do usuário é adicionado ao `PATH` via `containerEnv` (destino de _fallback_ do instalador nativo).
- Suporta distribuições baseadas em `apt`, `apk`, `dnf` e `yum` para dependências como `curl`.

## Uso

Após a criação do container, configure um provedor e chave de API (ex.: `export ANTHROPIC_API_KEY=...` ou o comando `/login`) e execute:

```bash
pi
```

Verifique a instalação com:

```bash
pi --version
```

Consulte a [documentação oficial](https://pi.dev/docs) para autenticação e configuração.
