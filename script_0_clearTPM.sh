#!/usr/bin/env bash

# -e: exit when any command fails
# -x: all executed commands are printed to the terminal
# -o pipefail: prevents errors in a pipeline from being masked
#set -exo pipefail

####################################################
# Start fresh
####################################################
tpm2_clear -c p

chmod 777 *.sh

echo "script Complete...."