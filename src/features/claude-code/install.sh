#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Instala o Claude Code (CLI oficial da Anthropic).
# Docs: https://docs.anthropic.com/claude-code
#-------------------------------------------------------------------------------------------------------------
set -e

# Opções da feature (injetadas em MAIÚSCULAS pelo dev container CLI)
CLAUDE_VERSION="${VERSION:-latest}"
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

# Garante que curl e ca-certificates estejam presentes (necessários para o instalador nativo).
ensure_curl() {
	if ! type curl >/dev/null 2>&1; then
		echo "-> Instalando curl (dependência ausente)..."
		install_packages curl ca-certificates
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
install_via_npm() {
	if ! type npm >/dev/null 2>&1; then
		return 1
	fi

	local pkg="@anthropic-ai/claude-code"
	if [ "$CLAUDE_VERSION" != "latest" ]; then
		pkg="${pkg}@${CLAUDE_VERSION}"
	fi

	echo "-> Instalando ${pkg} via npm..."
	npm install -g "$pkg"
}

# Instala via instalador oficial da Anthropic (binário em ~/.local/bin do usuário remoto).
install_via_native() {
	ensure_curl

	local arg=""
	if [ "$CLAUDE_VERSION" != "latest" ]; then
		arg="$CLAUDE_VERSION"
	fi

	echo "-> Instalando Claude Code via instalador oficial para o usuário '${USERNAME}'..."
	run_as_user "curl -fsSL https://claude.ai/install.sh | bash -s -- ${arg}"
}

# ------------------------------------------------------------------------------
# Orquestração
# ------------------------------------------------------------------------------

echo "Ativando a feature 'claude-code' (versão='${CLAUDE_VERSION}', método='${INSTALL_METHOD}')..."

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
			echo "-> npm indisponível; recorrendo ao instalador nativo."
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

echo "Feature 'claude-code' instalada com sucesso!"
