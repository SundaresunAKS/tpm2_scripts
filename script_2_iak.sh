#!/usr/bin/env bash

# -e: exit when any command fails
# -x: all executed commands are printed to the terminal
# -o pipefail: prevents errors in a pipeline from being masked
#set -exo pipefail


    # 7.3.6.1 Computing PA User Policy
    # Couples the authorization of an object to the TPM_RH_ENDORSEMENT (=0x4000000b)
    # Policy hash (SHA256): 837197674484b3f81a90cc8d46a5d724fd52d76e06520b64f2a1da1b331469aa
    tpm2_startauthsession -S session.ctx -g sha256
    tpm2_policysecret -S session.ctx -c e -L secret_eh.policy
    tpm2_flushcontext session.ctx


    # 7.3.6.2 Computing Certify Policy
    # 7.3.6.1 + Restricts a key for Certify use only
    # Policy hash (SHA256): b2a69e6391e2684a0fe752d39e14acd2e5cb922e4bd035830eea31f2aabe9870
    tpm2_startauthsession -S session.ctx -g sha256
    tpm2_policysecret -S session.ctx -c e
    tpm2_policycommandcode -S session.ctx TPM2_CC_Certify -L secret_eh+command_certify.policy
    tpm2_flushcontext session.ctx

    # 7.3.6.3 Computing Activate Credential Policy
    # 7.3.6.1 + Restricts a key for ActivateCredential use only
    # Policy hash (SHA256): cd9917cf18c3848c3a2e606986a066c68142f9bc2710a278287a650ca3bbf245
    tpm2_startauthsession -S session.ctx -g sha256
    tpm2_policysecret -S session.ctx -c e
    tpm2_policycommandcode -S session.ctx TPM2_CC_ActivateCredential -L secret_eh+command_activatecredential.policy
    tpm2_flushcontext session.ctx

            dd bs=34 count=1 </dev/zero >zeros-34.dat
            ## Attestation Key / IAK
            tpm2_nvdefine -C o -g sha256 -a "policywrite|writeall|ppread|ownerread|authread|policyread|no_da" -L secret_eh.policy -s 34 0x01c90018
            ## Set the "written" attribute
            tpm2_startauthsession -S session.ctx -g sha256 --policy-session
            tpm2_policysecret -S session.ctx -c e
            tpm2_nvwrite -P session:session.ctx -i zeros-34.dat 0x01c90018
            tpm2_flushcontext session.ctx
            tpm2_nvreadpublic 0x01c90018

    ## Attestation Key / IAK
    ## Policy hash (SHA256): 101e689dadf145222412c05b76e14532af1e5c74208e0ae7cdb0cff1906c8a09
    tpm2_startauthsession -S session.ctx -g sha256
    tpm2_policyauthorizenv -S session.ctx -L authorize_nv_iak.policy 0x01c90018
    tpm2_flushcontext session.ctx



    ## Attestation Key / IAK
    tpm2_startauthsession -S session.ctx -g sha256
    tpm2_policyor -S session.ctx -L iak.policy sha256:secret_eh.policy,secret_eh+command_certify.policy,secret_eh+command_activatecredential.policy,authorize_nv_iak.policy
    tpm2_flushcontext session.ctx



# Recoverable IDevID/IAK Key and Policy Details
echo 000149414b | xxd -r -p > iak.unique
tpm2_createprimary -C e -g sha256 -G rsa2048:rsassa:null -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|adminwithpolicy|restricted|sign" -L iak.policy -u iak.unique -c iak.ctx

tpm2_readpublic -c iak.ctx -f tpmt -o iak.public.tpmt

tpm2_readpublic -c iak.ctx -f pem -o iak.public.pem

