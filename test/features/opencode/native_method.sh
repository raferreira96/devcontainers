#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via instalador oficial (installMethod=native), sem Node.js.
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "opencode está no PATH" bash -c "command -v opencode"
check "opencode --version" bash -c "opencode --version"

reportResults
