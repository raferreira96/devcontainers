#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Instala o Pi (agente de codificação de código aberto, BYOK, para o terminal).
# Docs: https://pi.dev/docs
#-------------------------------------------------------------------------------------------------------------
set -e

# Opções da feature (injetadas em MAIÚSCULAS pelo dev container CLI)
PI_VERSION="${VERSION:-latest}"
INSTALL_METHOD="${INSTALLMETHOD:-auto}"

# Usuário remoto injetado pelo dev container CLI. O script roda como root.
USERNAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-/root}"

if [ "$(id -u)" -ne 0 ]; then
	echo "(!) Este script precisa ser executado como root. Use sudo, su, ou adicione \"USER root\" ao seu Dockerfile."
	exit 1
fi

# ------------------------------------------------------------------------------
# Utilitários
# ------------------------------------------------------------------------------

# Detecta o gerenciador de pacotes disponível na distribuição.
detect_pkg_manager() {
	if type apt-get >/dev/null 2>&1; then
		echo "apt"
	elif type apk >/dev/null 2>&1; then
		echo "apk"
	elif type dnf >/dev/null 2>&1; then
		echo "dnf"
	elif type yum >/dev/null 2>&1; then
		echo "yum"
	else
		echo "unknown"
	fi
}

PKG_MANAGER="$(detect_pkg_manager)"
APT_UPDATED="false"

# Instala pacotes de sistema de forma idempotente, cobrindo múltiplas distros.
install_packages() {
	case "$PKG_MANAGER" in
		apt)
			if [ "$APT_UPDATED" = "false" ]; then
				apt-get update -y
				APT_UPDATED="true"
			fi
			DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
			;;
		apk)
			apk add --no-cache "$@"
			;;
		dnf)
			dnf install -y "$@"
			;;
		yum)
			yum install -y "$@"
			;;
		*)
			echo "(!) Gerenciador de pacotes não suportado. Instale manualmente: $*"
			return 1
			;;
	esac
}

# Garante que uma dependência esteja presente, instalando o pacote informado se faltar.
ensure_cmd() {
	local cmd="$1"
	shift
	if ! type "$cmd" >/dev/null 2>&1; then
		echo "-> Instalando '${cmd}' (dependência ausente)..."
		install_packages "$@"
	fi
}

# Executa um comando como o usuário remoto (ou direto, se for root).
run_as_user() {
	if [ "$USERNAME" = "root" ] || [ -z "$USERNAME" ]; then
		bash -c "$1"
	else
		su "$USERNAME" -c "$1"
	fi
}

# ------------------------------------------------------------------------------
# Métodos de instalação
# ------------------------------------------------------------------------------

# Instala via npm global. Requer node/npm previamente disponíveis (feature node).
# Usa --ignore-scripts, recomendado pela documentação do Pi (não requer scripts de instalação).
install_via_npm() {
	if ! type npm >/dev/null 2>&1; then
		return 1
	fi

	local pkg="@earendil-works/pi-coding-agent"
	if [ "$PI_VERSION" != "latest" ]; then
		pkg="${pkg}@${PI_VERSION}"
	fi

	echo "-> Instalando ${pkg} via npm..."
	npm install -g --ignore-scripts "$pkg"
}

# Garante Node.js/npm presentes, fazendo bootstrap via NodeSource quando ausentes.
# O Pi é uma aplicação Node e exige Node.js >= 22.19 em tempo de execução.
ensure_node() {
	if type npm >/dev/null 2>&1; then
		return 0
	fi

	if [ "$PKG_MANAGER" != "apt" ]; then
		echo "(!) Bootstrap automático do Node.js suportado apenas em distros baseadas em apt. Adicione a feature 'ghcr.io/devcontainers/features/node' antes desta."
		return 1
	fi

	echo "-> Node.js/npm ausentes; instalando Node.js 22.x via NodeSource..."
	ensure_cmd curl curl ca-certificates
	curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
	install_packages nodejs
}

# Instala o Pi de forma autossuficiente: garante o Node.js (bootstrap se
# necessário) e instala via npm global. O instalador oficial (pi.dev) exige um
# terminal interativo, inviável em builds de container.
install_via_native() {
	ensure_node
	install_via_npm
}

# ------------------------------------------------------------------------------
# Orquestração
# ------------------------------------------------------------------------------

echo "Ativando a feature 'pi' (versão='${PI_VERSION}', método='${INSTALL_METHOD}')..."

case "$INSTALL_METHOD" in
	npm)
		if ! install_via_npm; then
			echo "(!) Método 'npm' selecionado, mas npm não está disponível. Adicione a feature 'ghcr.io/devcontainers/features/node' antes desta."
			exit 1
		fi
		;;
	native)
		install_via_native
		;;
	auto)
		if ! install_via_npm; then
			echo "-> npm indisponível; instalando Node.js e usando npm."
			install_via_native
		fi
		;;
	*)
		echo "(!) installMethod inválido: '${INSTALL_METHOD}'. Use 'auto', 'npm' ou 'native'."
		exit 1
		;;
esac

# Limpeza de listas do apt para reduzir o tamanho da imagem.
if [ "$PKG_MANAGER" = "apt" ] && [ "$APT_UPDATED" = "true" ]; then
	rm -rf /var/lib/apt/lists/*
fi

echo "Feature 'pi' instalada com sucesso!"
