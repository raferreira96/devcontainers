# OpenCode (opencode)

Instala o [OpenCode](https://opencode.ai/docs), o agente de codificação de código aberto para desenvolvimento assistido por IA diretamente no terminal.

## Exemplo de uso

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/opencode:1": {}
}
```

## Opções

| Opção           | Tipo   | Padrão   | Descrição                                                                                                                     |
| --------------- | ------ | -------- | --------------------------------------------------------------------------------------------------------------------------- |
| `version`       | string | `latest` | Versão do OpenCode a instalar: `latest` ou uma versão específica (ex.: `1.0.180`).                                          |
| `installMethod` | string | `auto`   | Método de instalação: `auto` (npm com fallback para o instalador nativo), `npm` (npm global) ou `native` (instalador oficial). |

## Métodos de instalação

- **`auto`** (padrão): usa `npm install -g opencode-ai` quando o `npm` está disponível; caso contrário, recorre ao instalador oficial do OpenCode.
- **`npm`**: força a instalação via npm global (pacote `opencode-ai`). Requer Node.js — combine com a feature [`node`](https://github.com/devcontainers/features/tree/main/src/node).
- **`native`**: força o instalador oficial (`https://opencode.ai/install`), que coloca o binário em `~/.opencode/bin` do usuário remoto. Não requer Node.js.

## Exemplos

### Com Node.js (via npm)

```jsonc
"features": {
    "ghcr.io/devcontainers/features/node:1": {},
    "ghcr.io/raferreira96/devcontainers/opencode:1": {
        "installMethod": "npm"
    }
}
```

### Sem Node.js (instalador nativo)

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/opencode:1": {
        "installMethod": "native",
        "version": "1.0.180"
    }
}
```

## Notas

- O script de instalação roda como `root` e detecta o usuário remoto via `_REMOTE_USER`, instalando o binário nativo no diretório do usuário correto.
- O instalador nativo aceita fixar a versão via variável `VERSION`, repassada automaticamente quando você define a opção `version`.
- A feature declara `installsAfter` para `common-utils` e `node`, garantindo que sejam instaladas antes quando presentes.
- O diretório `~/.opencode/bin` do usuário é adicionado ao `PATH` via `containerEnv`.
- Suporta distribuições baseadas em `apt`, `apk`, `dnf` e `yum` para dependências como `curl` e `unzip`.

## Uso

Após a criação do container, configure um provedor de modelos e execute:

```bash
opencode
```

Verifique a instalação com:

```bash
opencode --version
```

Consulte a [documentação oficial](https://opencode.ai/docs) para autenticação e configuração.
