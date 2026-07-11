#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Teste de fumaça do template 'node-postgis-redis-minio', executado por dentro do
# container de desenvolvimento (serviço 'app'). Uso local:
#
#   devcontainer up --workspace-folder src/templates/node-postgis-redis-minio
#   devcontainer exec --workspace-folder src/templates/node-postgis-redis-minio \
#       bash -c "$(cat test/templates/node-postgis-redis-minio/test.sh)"
#
# Não depende de bibliotecas externas: falha imediatamente em qualquer erro.
#-------------------------------------------------------------------------------------------------------------
set -euo pipefail

fail() { echo "FALHOU: $*" >&2; exit 1; }
pass() { echo "OK: $*"; }

# --- Runtime Node -------------------------------------------------------------
command -v node >/dev/null || fail "node não encontrado no PATH"
command -v npm  >/dev/null || fail "npm não encontrado no PATH"
pass "node $(node -v) / npm $(npm -v)"

# --- CLIs de IA ---------------------------------------------------------------
for cli in claude codex opencode agy pi rtk; do
	command -v "$cli" >/dev/null || fail "CLI de IA ausente: $cli"
	pass "CLI de IA presente: $cli"
done

# --- Variáveis de ambiente dos serviços --------------------------------------
[ -n "${DATABASE_URL:-}" ] || fail "DATABASE_URL não definida"
[ -n "${REDIS_URL:-}" ]    || fail "REDIS_URL não definida"
[ -n "${S3_ENDPOINT:-}" ]  || fail "S3_ENDPOINT não definida"
pass "variáveis de ambiente dos serviços definidas"

echo "Todos os testes passaram."
