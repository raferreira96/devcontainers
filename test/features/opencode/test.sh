#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Teste padrão da feature 'opencode' (usa a configuração default: version=latest, installMethod=auto).
#-------------------------------------------------------------------------------------------------------------
set -e

# Biblioteca de testes de features do dev containers.
source dev-container-features-test-lib

# O binário 'opencode' deve estar disponível no PATH.
check "opencode está no PATH" bash -c "command -v opencode"

# Deve reportar uma versão sem erro.
check "opencode --version" bash -c "opencode --version"

# Relata o resultado dos testes.
reportResults
