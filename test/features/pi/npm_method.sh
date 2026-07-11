#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via npm (installMethod=npm), com a feature 'node'.
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "pi está no PATH" bash -c "command -v pi"
check "pi --version" bash -c "pi --version"
check "instalado via npm" bash -c "npm ls -g @earendil-works/pi-coding-agent"

reportResults
