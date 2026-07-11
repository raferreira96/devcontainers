#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Instala o Codex CLI (agente de codificação de código aberto da OpenAI).
# Docs: https://github.com/openai/codex
#-------------------------------------------------------------------------------------------------------------
set -e

# Opções da feature (injetadas em MAIÚSCULAS pelo dev container CLI)
CODEX_VERSION="${VERSION:-latest}"
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

	local pkg="@openai/codex"
	if [ "$CODEX_VERSION" != "latest" ]; then
		pkg="${pkg}@${CODEX_VERSION}"
	fi

	echo "-> Instalando ${pkg} via npm..."
	npm install -g "$pkg"
}

# Instala via binário oficial das releases do GitHub (em ~/.local/bin do usuário remoto).
# Não requer Node.js.
install_via_native() {
	ensure_cmd curl curl ca-certificates
	ensure_cmd tar tar
	ensure_cmd gzip gzip

	# Mapeia a arquitetura do host para o alvo (target) das releases da OpenAI.
	local arch target
	arch="$(uname -m)"
	case "$arch" in
		x86_64 | amd64) target="x86_64-unknown-linux-musl" ;;
		aarch64 | arm64) target="aarch64-unknown-linux-musl" ;;
		*)
			echo "(!) Arquitetura não suportada pelo instalador nativo: '${arch}'. Use installMethod=npm."
			return 1
			;;
	esac

	local asset="codex-${target}.tar.gz"
	local url
	if [ "$CODEX_VERSION" = "latest" ]; then
		url="https://github.com/openai/codex/releases/latest/download/${asset}"
	else
		# Aceita '0.144.1', 'v0.144.1' ou o formato completo 'rust-v0.144.1'.
		local tag="$CODEX_VERSION"
		case "$tag" in
			rust-v*) ;;
			v*) tag="rust-${tag}" ;;
			*) tag="rust-v${tag}" ;;
		esac
		url="https://github.com/openai/codex/releases/download/${tag}/${asset}"
	fi

	local tmp
	tmp="$(mktemp -d)"
	# shellcheck disable=SC2064
	trap "rm -rf '${tmp}'" RETURN

	echo "-> Baixando Codex CLI de ${url}..."
	curl -fsSL "$url" -o "${tmp}/codex.tar.gz"
	tar -xzf "${tmp}/codex.tar.gz" -C "$tmp"

	# O binário extraído tem o nome do target (ex.: codex-x86_64-unknown-linux-musl);
	# localiza-o e renomeia para 'codex'.
	local bin
	bin="$(find "$tmp" -maxdepth 2 -type f -name 'codex*' ! -name '*.tar.gz' | head -n1)"
	if [ -z "$bin" ]; then
		echo "(!) Não foi possível localizar o binário do Codex no arquivo baixado."
		return 1
	fi

	# Instala em um diretório do PATH global para funcionar com qualquer usuário
	# remoto (a variável containerEnv HOME não é resolvida em tempo de build).
	install -d -m 0755 /usr/local/bin
	install -m 0755 "$bin" /usr/local/bin/codex
}

# ------------------------------------------------------------------------------
# Orquestração
# ------------------------------------------------------------------------------

echo "Ativando a feature 'codex' (versão='${CODEX_VERSION}', método='${INSTALL_METHOD}')..."

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
			echo "-> npm indisponível; recorrendo ao binário nativo."
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

echo "Feature 'codex' instalada com sucesso!"
