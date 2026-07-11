# Imagem de desenvolvimento Node.js para Dev Containers.
# Baseada na imagem oficial do Node.js (Debian bookworm) e já traz
# npm, Yarn e pnpm prontos para uso.
#
# A tag da imagem base pode ser sobrescrita no build:
#   docker build --build-arg VARIANT=20-bookworm ...
ARG VARIANT="22-bookworm"
FROM node:${VARIANT}

# Metadados OCI (aparecem no GHCR e em ferramentas de inspeção).
LABEL org.opencontainers.image.source="https://github.com/raferreira96/devcontainers" \
      org.opencontainers.image.description="Imagem de desenvolvimento Node.js com npm, Yarn e pnpm para Dev Containers." \
      org.opencontainers.image.licenses="MIT"

# Versões dos gerenciadores gerenciados pelo Corepack.
# 'stable'/'latest' facilitam manter atualizado; podem ser fixados para builds reprodutíveis.
ARG YARN_VERSION="stable"
ARG PNPM_VERSION="latest"

# Evita prompts interativos do apt durante o build.
ENV DEBIAN_FRONTEND=noninteractive

# Aplica atualizações de segurança e garante utilitários comuns de desenvolvimento.
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
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Cache compartilhado do Corepack, legível por todos os usuários. Precisa ser
# definido via ENV para que o usuário não-root 'node' use o mesmo cache em runtime;
# caso contrário a ativação feita como root não valeria para ele.
ENV COREPACK_HOME="/usr/local/share/corepack" \
    COREPACK_ENABLE_DOWNLOAD_PROMPT="0"

# Habilita o Corepack (incluído no Node) para gerenciar Yarn e pnpm e fixa as
# versões ativas no cache compartilhado. Assim os três gerenciadores ficam
# disponíveis sem prompts de download em runtime. O npm já vem com a imagem base.
RUN corepack enable --install-directory /usr/local/bin \
    && corepack prepare "yarn@${YARN_VERSION}" --activate \
    && corepack prepare "pnpm@${PNPM_VERSION}" --activate \
    && chmod -R a+rX "${COREPACK_HOME}"

# Diretório global do pnpm no HOME do usuário não-root 'node'. Os executáveis
# de pacotes instalados com 'pnpm add -g' ficam em ${PNPM_HOME}/bin.
ENV PNPM_HOME="/home/node/.local/share/pnpm"
ENV PATH="${PNPM_HOME}/bin:${PATH}"

# Cria o diretório do pnpm com o dono correto (instalações globais sem sudo) e
# garante o PATH também em shells de login (o VS Code abre um login shell, que
# reconstrói o PATH a partir do /etc/profile e descartaria o valor do ENV acima).
RUN mkdir -p "${PNPM_HOME}/bin" \
    && chown -R node:node "${PNPM_HOME}" \
    && printf 'export PNPM_HOME="%s"\ncase ":$PATH:" in *":$PNPM_HOME/bin:"*) ;; *) export PATH="$PNPM_HOME/bin:$PATH";; esac\n' \
        "${PNPM_HOME}" > /etc/profile.d/pnpm.sh

# Boas práticas de Dev Container: rodar como usuário não-root.
# A imagem oficial do Node já provê o usuário 'node' (UID/GID 1000).
USER node

# Diretório padrão onde o Dev Container monta o código-fonte.
WORKDIR /workspaces
