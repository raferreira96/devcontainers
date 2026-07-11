# Imagem de desenvolvimento PHP para Dev Containers.
# Baseada na imagem OFICIAL do PHP (Debian bookworm), já traz um amplo conjunto
# de extensões habilitadas, Xdebug (com baixo overhead), OPcache + JIT e Composer.
#
# A tag da imagem base pode ser sobrescrita no build. Prefira variantes CLI, que
# são as mais versáteis para desenvolvimento (servidor embutido, artisan, etc.):
#   docker build --build-arg VARIANT=8.3-cli-bookworm ...
ARG VARIANT="8.4-cli-bookworm"
FROM php:${VARIANT}

# Metadados OCI (aparecem no GHCR e em ferramentas de inspeção).
LABEL org.opencontainers.image.source="https://github.com/raferreira96/devcontainers" \
      org.opencontainers.image.description="Imagem de desenvolvimento PHP com Xdebug, OPcache+JIT, Composer e extensões comuns para Dev Containers." \
      org.opencontainers.image.licenses="MIT"

# Usuário não-root criado abaixo (a imagem oficial do PHP roda como root).
ARG USERNAME="vscode"
ARG USER_UID="1000"
ARG USER_GID="${USER_UID}"

# Evita prompts interativos do apt durante o build.
ENV DEBIAN_FRONTEND=noninteractive

# Aplica atualizações de segurança e instala utilitários comuns de desenvolvimento.
# 'unzip' e 'git' também melhoram bastante o desempenho do Composer.
# Uma única camada + limpeza do cache do apt mantêm a imagem enxuta.
RUN apt-get update \
    && apt-get -y upgrade --no-install-recommends \
    && apt-get -y install --no-install-recommends \
        ca-certificates \
        curl \
        git \
        less \
        openssh-client \
        procps \
        sudo \
        unzip \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# install-php-extensions (mlocati) resolve automaticamente as dependências de
# sistema de cada extensão, compila/habilita tudo e depois remove os pacotes de
# build — mantendo a imagem menor e reproduzível. Ver github.com/mlocati/docker-php-extension-installer
COPY --from=mlocati/php-extension-installer:2 /usr/bin/install-php-extensions /usr/local/bin/

# Conjunto amplo de extensões para cobrir a maioria dos frameworks e projetos
# PHP (Laravel, Symfony, WordPress, etc.), além de OPcache, Xdebug e Composer.
RUN install-php-extensions \
        apcu \
        bcmath \
        bz2 \
        calendar \
        exif \
        gd \
        gettext \
        gmp \
        igbinary \
        imagick \
        intl \
        ldap \
        mbstring \
        memcached \
        mysqli \
        opcache \
        pcntl \
        pcov \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        redis \
        soap \
        sockets \
        sysvmsg \
        sysvsem \
        sysvshm \
        xdebug \
        xsl \
        zip \
        zstd \
        @composer

# Usa o php.ini de DESENVOLVIMENTO fornecido pela imagem oficial como base
# (display_errors ligado, error_reporting = E_ALL) e adiciona nossos ajustes de
# OPcache/JIT, Xdebug e hardening como drop-ins em conf.d (carregados por último).
RUN cp "${PHP_INI_DIR}/php.ini-development" "${PHP_INI_DIR}/php.ini"
COPY conf.d/ "${PHP_INI_DIR}/conf.d/"

# Cria o usuário não-root com sudo sem senha (padrão em Dev Containers) e
# prepara o diretório de trabalho. Princípio do menor privilégio no runtime.
RUN groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}" \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}" \
    && mkdir -p /workspaces \
    && chown "${USER_UID}:${USER_GID}" /workspaces

# Composer: cache/instalações globais no HOME do usuário e o bin global no PATH,
# inclusive em login shells (o terminal do VS Code reconstrói o PATH a partir do
# /etc/profile). Assim 'composer global require' funciona sem sudo.
ENV COMPOSER_HOME="/home/${USERNAME}/.composer"
ENV PATH="${COMPOSER_HOME}/vendor/bin:${PATH}"
RUN mkdir -p "${COMPOSER_HOME}" \
    && chown -R "${USER_UID}:${USER_GID}" "${COMPOSER_HOME}" \
    && printf 'export COMPOSER_HOME="%s"\ncase ":$PATH:" in *":$COMPOSER_HOME/vendor/bin:"*) ;; *) export PATH="$COMPOSER_HOME/vendor/bin:$PATH";; esac\n' \
        "${COMPOSER_HOME}" > /etc/profile.d/composer.sh

# Boas práticas de Dev Container: rodar como usuário não-root.
USER ${USERNAME}

# Diretório padrão onde o Dev Container monta o código-fonte.
WORKDIR /workspaces
