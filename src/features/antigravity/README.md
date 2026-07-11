# Antigravity CLI (antigravity)

Instala o [Antigravity CLI](https://antigravity.google/docs/cli) (`agy`), o agente de codificação da Google que traz as capacidades de raciocínio, execução e orquestração do Antigravity diretamente para o terminal.

## Exemplo de uso

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/antigravity:1": {}
}
```

## Opções

Esta feature não possui opções: o Antigravity CLI é distribuído como um único binário e é instalado pelo instalador oficial da Google.

## Método de instalação

O Antigravity CLI é distribuído **apenas** via instalador nativo oficial (`https://antigravity.google/cli/install.sh`), que baixa um único binário Go (`agy`) para `~/.local/bin` do usuário remoto. Não requer Node.js nem Python.

> **Auto-atualização:** o `agy` se atualiza automaticamente em segundo plano durante o uso normal, portanto não há opção de fixação de versão nesta feature.

## Notas

- O script de instalação roda como `root` e detecta o usuário remoto via `_REMOTE_USER`, instalando o binário no diretório `~/.local/bin` do usuário correto.
- A feature declara `installsAfter` para `common-utils`, garantindo que seja instalada antes quando presente.
- O diretório `~/.local/bin` do usuário é adicionado ao `PATH` via `containerEnv`.
- Suporta distribuições baseadas em `apt`, `apk`, `dnf` e `yum` para dependências como `curl` e `tar`.

## Uso

Após a criação do container, autentique-se (fluxo de Sign-In do Google no navegador) e execute:

```bash
agy
```

Verifique a instalação com:

```bash
agy --version
```

Consulte a [documentação oficial](https://antigravity.google/docs/cli) para autenticação e configuração.
