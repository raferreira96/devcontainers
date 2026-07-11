#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via instalador oficial (installMethod=native), sem Node.js.
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "pi está no PATH" bash -c "command -v pi"
check "pi --version" bash -c "pi --version"

reportResults
