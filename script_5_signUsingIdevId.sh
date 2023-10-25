#!/usr/bin/env bash

# -e: exit when any command fails
# -x: all executed commands are printed to the terminal
# -o pipefail: prevents errors in a pipeline from being masked
#set -exo pipefail

# Create a dummy CSR for signing
echo "Construct the CSR according to the 13.1 TCG-CSR-IDEVID template." > idevid-dummy.csr

# Sign the dummy CSR using the IDevID
tpm2_startauthsession -S session.ctx -g sha256 --policy-session
tpm2_policysecret -S session.ctx -c e
tpm2_policyor -S session.ctx sha256:secret_eh.policy,secret_eh+command_certify.policy,secret_eh+command_activatecredential.policy,authorize_nv_idevid.policy
tpm2_sign -c 0x81020000 -g sha256 -p session:session.ctx -f plain -o csr.signature.plain idevid-dummy.csr
tpm2_flushcontext session.ctx

# Output the TPMT_PUBLIC struct
tpm2_readpublic -c 0x81020000 -f pem -o idevid.public.pem


# Verify the CSR signature
openssl dgst -sha256 -verify idevid.public.pem -keyform pem -signature csr.signature.plain idevid-dummy.csr

tpm2_flushcontext -t