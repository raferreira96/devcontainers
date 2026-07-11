# Imagem Dev Container — PHP

Imagem de desenvolvimento baseada na [imagem oficial do PHP](https://hub.docker.com/_/php)
(Debian *bookworm*), já com um amplo conjunto de extensões habilitadas,
**Xdebug**, **OPcache + JIT** e **Composer** prontos para uso.

Publicada no GHCR:

```
ghcr.io/raferreira96/devcontainers/php:latest
```

## O que vem na imagem

| Ferramenta | Origem | Observação |
| ---------- | ------ | ---------- |
| **PHP** | imagem oficial `php` | 8.4 (CLI) por padrão |
| **Composer** | [install-php-extensions](https://github.com/mlocati/docker-php-extension-installer) | `@composer`, bin global no `PATH` |
| **Xdebug** | install-php-extensions | carregado, ativado sob demanda (*trigger*) |
| **OPcache** | install-php-extensions | ligado e ajustado para dev |
| git, curl, unzip, ssh, less, procps, sudo | apt | utilitários comuns de dev |

### Extensões incluídas

`apcu`, `bcmath`, `bz2`, `calendar`, `exif`, `gd`, `gettext`, `gmp`, `igbinary`,
`imagick`, `intl`, `ldap`, `mbstring`, `memcached`, `mysqli`, `opcache`,
`pcntl`, `pcov`, `pdo_mysql`, `pdo_pgsql`, `pgsql`, `redis`, `soap`, `sockets`,
`sysvmsg`, `sysvsem`, `sysvshm`, `xdebug`, `xsl`, `zip`, `zstd`.

Instaladas via [`install-php-extensions`](https://github.com/mlocati/docker-php-extension-installer),
que resolve as dependências de sistema de cada extensão e remove os pacotes de
build ao final, mantendo a imagem enxuta.

## Boas práticas aplicadas

- **Baseada na imagem oficial do PHP**, sem reinventar o runtime.
- **Usuário não-root `vscode`** (UID/GID 1000) com `sudo` sem senha — princípio
  do menor privilégio no runtime.
- **`expose_php = Off`** para não revelar a versão do PHP.
- **Camadas enxutas**: uma única camada de `apt` com limpeza do cache
  (`rm -rf /var/lib/apt/lists/*`) e extensões via `install-php-extensions`.
- **Versão parametrizável** via `ARG VARIANT` (ex.: `8.3-cli-bookworm`).
- **`composer global require` sem `sudo`**: `COMPOSER_HOME` configurado e o bin
  global adicionado ao `PATH`, inclusive em *login shells* (via `/etc/profile.d`).
- **Rótulos OCI** (`org.opencontainers.image.*`) para rastreabilidade no GHCR.

## Performance vs. Xdebug

O Xdebug fica **carregado, porém inativo** por padrão
(`xdebug.start_with_request = trigger`): o overhead só aparece quando a
requisição traz o gatilho `XDEBUG_TRIGGER` (cookie/GET/POST) ou a variável de
ambiente correspondente. Assim você mantém o dia a dia rápido e liga o depurador
apenas quando precisa.

Para ajustar em runtime, use a variável de ambiente **`XDEBUG_MODE`** (tem
precedência sobre o `php.ini`):

```jsonc
// devcontainer.json — desligar por completo (máxima performance)
"remoteEnv": { "XDEBUG_MODE": "off" }

// ...ou ativar cobertura/trace além do debug
"remoteEnv": { "XDEBUG_MODE": "debug,develop,coverage" }
```

O **OPcache** fica ligado com `validate_timestamps = 1` e `revalidate_freq = 0`,
então edições no código são refletidas imediatamente — o cache de bytecode
acelera a execução sem atrapalhar o fluxo de desenvolvimento.

> **JIT desativado de propósito.** O JIT do OPcache é incompatível com o Xdebug
> (que sobrescreve `zend_execute_ex()`); mantê-lo ligado apenas emitiria um
> aviso *"JIT disabled"* a cada execução, sem ganho real. Se você precisa do
> JIT, remova/desabilite o Xdebug e defina `opcache.jit = tracing`.

## Como usar

### 1. Referenciando a imagem publicada

No `devcontainer.json` do seu projeto:

```jsonc
{
  "name": "Meu projeto PHP",
  "image": "ghcr.io/raferreira96/devcontainers/php:latest",
  "remoteUser": "vscode"
}
```

### 2. Construindo a partir do Dockerfile

A pasta [`.devcontainer/`](.devcontainer/) traz um `devcontainer.json` de exemplo
que constrói a imagem localmente. Basta abrir esta pasta no VS Code e executar
**Dev Containers: Reopen in Container**.

Para trocar a versão do PHP no build:

```bash
docker build --build-arg VARIANT=8.3-cli-bookworm -t php-dev .devcontainer
```

## Verificação rápida

```bash
php -v                          # PHP 8.4.x
composer --version
php -m                          # lista as extensões (Xdebug, Zend OPcache, ...)
php -r 'var_dump(function_exists("opcache_get_status"));'
```
