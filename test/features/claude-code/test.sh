#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Teste padrão da feature 'claude-code' (usa a configuração default: version=latest, installMethod=auto).
#-------------------------------------------------------------------------------------------------------------
set -e

# Biblioteca de testes de features do dev containers.
source dev-container-features-test-lib

# O binário 'claude' deve estar disponível no PATH.
check "claude está no PATH" bash -c "command -v claude"

# Deve reportar uma versão sem erro.
check "claude --version" bash -c "claude --version"

# Relata o resultado dos testes.
reportResults
