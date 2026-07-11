#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via npm (installMethod=npm), com a feature 'node'.
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "codex está no PATH" bash -c "command -v codex"
check "codex --version" bash -c "codex --version"
check "instalado via npm" bash -c "npm ls -g @openai/codex"

reportResults
