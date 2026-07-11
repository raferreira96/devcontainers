#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via npm (installMethod=npm), com a feature 'node'.
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "opencode está no PATH" bash -c "command -v opencode"
check "opencode --version" bash -c "opencode --version"
check "instalado via npm" bash -c "npm ls -g opencode-ai"

reportResults
