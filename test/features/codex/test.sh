#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Teste padrão da feature 'codex' (usa a configuração default: version=latest, installMethod=auto).
#-------------------------------------------------------------------------------------------------------------
set -e

# Biblioteca de testes de features do dev containers.
source dev-container-features-test-lib

# O binário 'codex' deve estar disponível no PATH.
check "codex está no PATH" bash -c "command -v codex"

# Deve reportar uma versão sem erro.
check "codex --version" bash -c "codex --version"

# Relata o resultado dos testes.
reportResults
