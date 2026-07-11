#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via instalador oficial (installMethod=native), sem Node.js.
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "claude está no PATH" bash -c "command -v claude"
check "claude --version" bash -c "claude --version"

reportResults
