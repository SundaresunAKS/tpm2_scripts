#!/usr/bin/env bash

# -e: exit when any command fails
# -x: all executed commands are printed to the terminal
# -o pipefail: prevents errors in a pipeline from being masked
#set -exo pipefail



# Comply with the IDevID access policy
tpm2_startauthsession -S session_idevid.ctx -g sha256 --policy-session
tpm2_policysecret -S session_idevid.ctx -c e
tpm2_policycommandcode -S session_idevid.ctx TPM2_CC_Certify
tpm2_policyor -S session_idevid.ctx sha256:secret_eh.policy,secret_eh+command_certify.policy,secret_eh+command_activatecredential.policy,authorize_nv_idevid.policy

# Comply with the IAK access policy
tpm2_startauthsession -S session_iak.ctx -g sha256 --policy-session
tpm2_policysecret -S session_iak.ctx -c e
tpm2_policycommandcode -S session_iak.ctx TPM2_CC_Certify
tpm2_policyor -S session_iak.ctx sha256:secret_eh.policy,secret_eh+command_certify.policy,secret_eh+command_activatecredential.policy,authorize_nv_iak.policy

# Certify the IDevID with the IAK
tpm2_certify -C iak.ctx -c 0x81020000 -p session:session_iak.ctx -P session:session_idevid.ctx -g sha256 -f tss -o idevid.attest.tpmb -s idevid.attest.signature.tss

tpm2_flushcontext session_idevid.ctx
tpm2_flushcontext session_iak.ctx




# Verify the signature of TPMB_ATTEST
# It only works if the tpm2_certify signature output format is set to 'tss', that is, if the '-f tss' option is used.
tpm2_verifysignature -c iak.ctx -g sha256 -m idevid.attest.tpmb -s idevid.attest.signature.tss

# tpm2_verifysignature -c iak.ctx -g sha256 -m zeros-34.dat -s idevid.attest.signature.tss -t result.txt
