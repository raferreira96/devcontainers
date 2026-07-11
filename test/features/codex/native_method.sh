#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via binário nativo (installMethod=native), sem Node.js.
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "codex está no PATH" bash -c "command -v codex"
check "codex --version" bash -c "codex --version"

reportResults
