#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação em base Debian, sem Node.js (o instalador nativo é a única via).
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "agy está no PATH" bash -c "command -v agy"
check "agy --version" bash -c "agy --version"

reportResults
