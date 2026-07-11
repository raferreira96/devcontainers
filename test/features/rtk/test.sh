#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Teste padrão da feature 'rtk' (usa a configuração default: version=latest, installMethod=auto).
#-------------------------------------------------------------------------------------------------------------
set -e

# Biblioteca de testes de features do dev containers.
source dev-container-features-test-lib

# O binário 'rtk' deve estar disponível no PATH.
check "rtk está no PATH" bash -c "command -v rtk"

# Deve reportar uma versão sem erro.
check "rtk --version" bash -c "rtk --version"

# Relata o resultado dos testes.
reportResults
