#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Instala o OpenCode (agente de codificação de código aberto para o terminal).
# Docs: https://opencode.ai/docs
#-------------------------------------------------------------------------------------------------------------
set -e

# Opções da feature (injetadas em MAIÚSCULAS pelo dev container CLI)
OPENCODE_VERSION="${VERSION:-latest}"
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
install_via_npm() {
	if ! type npm >/dev/null 2>&1; then
		return 1
	fi

	local pkg="opencode-ai"
	if [ "$OPENCODE_VERSION" != "latest" ]; then
		pkg="${pkg}@${OPENCODE_VERSION}"
	fi

	echo "-> Instalando ${pkg} via npm..."
	npm install -g "$pkg"
}

# Instala via instalador oficial do OpenCode (binário em ~/.opencode/bin do usuário remoto).
# Não requer Node.js.
install_via_native() {
	ensure_cmd curl curl ca-certificates
	ensure_cmd unzip unzip

	# Monta o comando do usuário remoto. Faz 'unset VERSION' para não vazar a
	# opção VERSION=latest da feature ao instalador oficial (que a interpretaria
	# como a release inexistente 'vlatest').
	local cmd="unset VERSION; export HOME='${USER_HOME}'; "
	if [ "$OPENCODE_VERSION" != "latest" ]; then
		cmd="${cmd}export VERSION='${OPENCODE_VERSION}'; "
	fi
	cmd="${cmd}curl -fsSL https://opencode.ai/install | bash"

	echo "-> Instalando o OpenCode via instalador oficial para o usuário '${USERNAME}'..."
	run_as_user "$cmd"

	# Expõe o binário em um diretório do PATH global (containerEnv HOME não é
	# resolvido em tempo de build).
	if [ -x "${USER_HOME}/.opencode/bin/opencode" ]; then
		ln -sf "${USER_HOME}/.opencode/bin/opencode" /usr/local/bin/opencode
	fi
}

# ------------------------------------------------------------------------------
# Orquestração
# ------------------------------------------------------------------------------

echo "Ativando a feature 'opencode' (versão='${OPENCODE_VERSION}', método='${INSTALL_METHOD}')..."

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

echo "Feature 'opencode' instalada com sucesso!"
