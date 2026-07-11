#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Instala o RTK (Rust Token Killer), um proxy de CLI que reduz o consumo de tokens.
# Docs: https://github.com/rtk-ai/rtk
#-------------------------------------------------------------------------------------------------------------
set -e

# Opções da feature (injetadas em MAIÚSCULAS pelo dev container CLI)
RTK_VERSION="${VERSION:-latest}"
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

# Mapeia a arquitetura do host para o target triple das releases do RTK.
# Observação: x86_64 usa musl; aarch64 usa gnu (conforme os assets publicados).
detect_target() {
	local arch
	arch="$(uname -m)"
	case "$arch" in
		x86_64 | amd64) echo "x86_64-unknown-linux-musl" ;;
		aarch64 | arm64) echo "aarch64-unknown-linux-gnu" ;;
		*)
			echo ""
			;;
	esac
}

# ------------------------------------------------------------------------------
# Métodos de instalação
# ------------------------------------------------------------------------------

# Instala via instalador oficial do RTK (com verificação de checksum).
# Direciona o RTK_INSTALL_DIR para /usr/local/bin para que o binário fique em um
# diretório do PATH global, funcionando com qualquer usuário remoto.
install_via_script() {
	ensure_cmd curl curl ca-certificates
	ensure_cmd tar tar

	local cmd="export RTK_INSTALL_DIR='/usr/local/bin'; "
	if [ "$RTK_VERSION" != "latest" ]; then
		# O instalador aceita a tag com prefixo 'v' (ex.: v0.43.0).
		local ver="$RTK_VERSION"
		case "$ver" in
			v*) ;;
			*) ver="v${ver}" ;;
		esac
		cmd="${cmd}export RTK_VERSION='${ver}'; "
	fi
	cmd="${cmd}curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh"

	echo "-> Instalando o RTK via instalador oficial..."
	install -d -m 0755 /usr/local/bin
	bash -c "$cmd"
}

# Instala via binário pré-compilado das releases do GitHub (em /usr/local/bin).
install_via_binary() {
	ensure_cmd curl curl ca-certificates
	ensure_cmd tar tar
	ensure_cmd gzip gzip

	local target
	target="$(detect_target)"
	if [ -z "$target" ]; then
		echo "(!) Arquitetura não suportada pelo instalador de binário: '$(uname -m)'."
		return 1
	fi

	local asset="rtk-${target}.tar.gz"
	local url
	if [ "$RTK_VERSION" = "latest" ]; then
		url="https://github.com/rtk-ai/rtk/releases/latest/download/${asset}"
	else
		# Aceita '0.43.0' ou 'v0.43.0'.
		local tag="$RTK_VERSION"
		case "$tag" in
			v*) ;;
			*) tag="v${tag}" ;;
		esac
		url="https://github.com/rtk-ai/rtk/releases/download/${tag}/${asset}"
	fi

	local tmp
	tmp="$(mktemp -d)"
	# shellcheck disable=SC2064
	trap "rm -rf '${tmp}'" RETURN

	echo "-> Baixando RTK de ${url}..."
	curl -fsSL "$url" -o "${tmp}/rtk.tar.gz"
	tar -xzf "${tmp}/rtk.tar.gz" -C "$tmp"

	# Localiza o binário 'rtk' extraído (pode estar em subdiretório).
	local bin
	bin="$(find "$tmp" -maxdepth 3 -type f -name 'rtk' | head -n1)"
	if [ -z "$bin" ]; then
		echo "(!) Não foi possível localizar o binário do RTK no arquivo baixado."
		return 1
	fi

	# Instala em um diretório do PATH global para funcionar com qualquer usuário remoto.
	install -d -m 0755 /usr/local/bin
	install -m 0755 "$bin" /usr/local/bin/rtk
}

# ------------------------------------------------------------------------------
# Orquestração
# ------------------------------------------------------------------------------

echo "Ativando a feature 'rtk' (versão='${RTK_VERSION}', método='${INSTALL_METHOD}')..."

case "$INSTALL_METHOD" in
	script)
		install_via_script
		;;
	binary)
		install_via_binary
		;;
	auto)
		if ! install_via_script; then
			echo "-> Instalador oficial falhou; recorrendo ao binário pré-compilado."
			install_via_binary
		fi
		;;
	*)
		echo "(!) installMethod inválido: '${INSTALL_METHOD}'. Use 'auto', 'script' ou 'binary'."
		exit 1
		;;
esac

# Limpeza de listas do apt para reduzir o tamanho da imagem.
if [ "$PKG_MANAGER" = "apt" ] && [ "$APT_UPDATED" = "true" ]; then
	rm -rf /var/lib/apt/lists/*
fi

echo "Feature 'rtk' instalada com sucesso!"
