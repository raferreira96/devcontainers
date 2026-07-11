#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Instala o Antigravity CLI (agy), o agente de codificação da Google para o terminal.
# Docs: https://antigravity.google/docs/cli
#-------------------------------------------------------------------------------------------------------------
set -e

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
# Instalação
# ------------------------------------------------------------------------------

# Instala via instalador oficial da Google (binário 'agy' em ~/.local/bin do usuário
# remoto). Não requer Node.js — é um único binário Go que se auto-atualiza.
install_via_native() {
	ensure_cmd curl curl ca-certificates
	ensure_cmd tar tar

	echo "-> Instalando o Antigravity CLI via instalador oficial para o usuário '${USERNAME}'..."
	run_as_user "export HOME='${USER_HOME}'; curl -fsSL https://antigravity.google/cli/install.sh | bash"
}

# ------------------------------------------------------------------------------
# Orquestração
# ------------------------------------------------------------------------------

echo "Ativando a feature 'antigravity'..."

install_via_native

# Limpeza de listas do apt para reduzir o tamanho da imagem.
if [ "$PKG_MANAGER" = "apt" ] && [ "$APT_UPDATED" = "true" ]; then
	rm -rf /var/lib/apt/lists/*
fi

echo "Feature 'antigravity' instalada com sucesso!"
