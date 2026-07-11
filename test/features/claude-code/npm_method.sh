#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via npm (installMethod=npm), com a feature 'node'.
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "claude está no PATH" bash -c "command -v claude"
check "claude --version" bash -c "claude --version"
check "instalado via npm" bash -c "npm ls -g @anthropic-ai/claude-code"

reportResults
