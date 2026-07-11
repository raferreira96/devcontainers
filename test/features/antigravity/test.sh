#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Teste padrão da feature 'antigravity' (configuração default).
#-------------------------------------------------------------------------------------------------------------
set -e

# Biblioteca de testes de features do dev containers.
source dev-container-features-test-lib

# O binário 'agy' deve estar disponível no PATH.
check "agy está no PATH" bash -c "command -v agy"

# Deve reportar uma versão sem erro (verificação não-interativa e segura para scripts).
check "agy --version" bash -c "agy --version"

# Relata o resultado dos testes.
reportResults
