# RTK - Rust Token Killer (rtk)

Instala o [RTK](https://github.com/rtk-ai/rtk) (Rust Token Killer), um proxy de CLI escrito em Rust que reduz o consumo de tokens em operações de desenvolvimento (60-90% de economia).

## Exemplo de uso

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/rtk:1": {}
}
```

## Opções

| Opção           | Tipo   | Padrão   | Descrição                                                                                                         |
| --------------- | ------ | -------- | --------------------------------------------------------------------------------------------------------------- |
| `version`       | string | `latest` | Versão do RTK a instalar: `latest` ou uma versão específica (ex.: `0.43.0`).                                     |
| `installMethod` | string | `auto`   | Método de instalação: `auto` (instalador oficial com fallback para o binário), `script` (instalador oficial) ou `binary` (binário das releases). |

## Métodos de instalação

- **`auto`** (padrão): usa o instalador oficial (`install.sh`), que faz verificação de checksum; caso falhe, recorre ao download direto do binário pré-compilado.
- **`script`**: força o instalador oficial do RTK, apontando `RTK_INSTALL_DIR` para `/usr/local/bin`.
- **`binary`**: baixa o binário pré-compilado direto das [releases do GitHub](https://github.com/rtk-ai/rtk/releases) e o instala em `/usr/local/bin`.

O RTK é escrito em Rust e distribuído como um binário único — **não requer Node.js**.

## Exemplos

### Versão específica

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/rtk:1": {
        "version": "0.43.0"
    }
}
```

### Forçando o binário pré-compilado

```jsonc
"features": {
    "ghcr.io/raferreira96/devcontainers/rtk:1": {
        "installMethod": "binary"
    }
}
```

## Notas

- O script de instalação roda como `root` e instala o binário em `/usr/local/bin`, disponível no `PATH` de qualquer usuário remoto.
- O binário pré-compilado é resolvido por arquitetura: `x86_64-unknown-linux-musl` (amd64) e `aarch64-unknown-linux-gnu` (arm64).
- ⚠️ Existe outro projeto chamado `rtk` (Rust Type Kit) no crates.io. Esta feature instala o **Rust Token Killer** de `rtk-ai/rtk`.
- Suporta distribuições baseadas em `apt`, `apk`, `dnf` e `yum` para dependências como `curl` e `tar`.

## Uso

Após a criação do container, verifique a instalação com:

```bash
rtk --version
```

Consulte os analytics de economia de tokens com:

```bash
rtk gain
```

Consulte a [documentação oficial](https://github.com/rtk-ai/rtk) para configuração completa e integração com o Claude Code.
