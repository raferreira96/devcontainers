#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Teste de fumaça da imagem 'php', executado por dentro do container. Uso local:
#
#   docker build -t php-dev src/images/php/.devcontainer
#   docker run --rm -v "$PWD/test/images/php:/t" php-dev bash /t/test.sh
#
# Não depende de bibliotecas externas: falha imediatamente em qualquer erro.
#-------------------------------------------------------------------------------------------------------------
set -euo pipefail

fail() { echo "FALHOU: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

# --- Runtime PHP e Composer ---------------------------------------------------
command -v php      >/dev/null || fail "php não encontrado no PATH"
command -v composer >/dev/null || fail "composer não encontrado no PATH"
pass "php $(php -r 'echo PHP_VERSION;') / composer presente"

# --- Extensões-chave ativas ---------------------------------------------------
for ext in Xdebug "Zend OPcache" gd intl mbstring pdo_mysql pdo_pgsql redis zip; do
	php -m | grep -qi -- "$ext" || fail "extensão ausente: $ext"
	pass "extensão presente: $ext"
done

# --- OPcache habilitado e funcional -------------------------------------------
[ "$(php -r 'var_export(opcache_get_status(false) !== false);' 2>/dev/null)" = "true" ] \
	|| fail "OPcache não está ativo"
pass "OPcache ativo"

# --- PHP inicia sem warnings (ex.: JIT vs. Xdebug) ----------------------------
# Startup limpo garante que ferramentas que capturam o stdout do php não recebam
# ruído. O JIT é desativado de propósito por ser incompatível com o Xdebug.
startup="$(php -r ';' 2>&1)"
[ -z "$startup" ] || fail "php emitiu mensagens na inicialização: $startup"
pass "PHP inicia sem warnings"

# --- Hardening: versão do PHP não exposta -------------------------------------
[ "$(php -r 'echo ini_get("expose_php");')" != "1" ] || fail "expose_php deveria estar Off"
pass "expose_php Off"

# --- Xdebug carregado, porém inativo por padrão (performance) -----------------
[ "$(php -r 'echo ini_get("xdebug.start_with_request");')" = "trigger" ] \
	|| fail "xdebug.start_with_request deveria ser 'trigger'"
pass "Xdebug em modo trigger (baixo overhead)"

# --- Usuário não-root ---------------------------------------------------------
[ "$(id -u)" != "0" ] || fail "container está rodando como root"
pass "rodando como usuário não-root ($(id -un))"

echo "Todos os testes passaram."
