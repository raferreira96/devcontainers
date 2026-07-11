#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Teste padrão da feature 'pi' (usa a configuração default: version=latest, installMethod=auto).
#-------------------------------------------------------------------------------------------------------------
set -e

# Biblioteca de testes de features do dev containers.
source dev-container-features-test-lib

# O binário 'pi' deve estar disponível no PATH.
check "pi está no PATH" bash -c "command -v pi"

# Deve reportar uma versão sem erro.
check "pi --version" bash -c "pi --version"

# Relata o resultado dos testes.
reportResults
