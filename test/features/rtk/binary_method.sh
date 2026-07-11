#!/bin/bash
#-------------------------------------------------------------------------------------------------------------
# Cenário: instalação forçada via binário pré-compilado das releases (installMethod=binary).
#-------------------------------------------------------------------------------------------------------------
set -e

source dev-container-features-test-lib

check "rtk está no PATH" bash -c "command -v rtk"
check "rtk --version" bash -c "rtk --version"

reportResults
