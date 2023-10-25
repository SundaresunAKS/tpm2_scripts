#!/usr/bin/env bash

# -e: exit when any command fails
# -x: all executed commands are printed to the terminal
# -o pipefail: prevents errors in a pipeline from being masked
#set -exo pipefail

        dd bs=34 count=1 </dev/zero >zeros-34.dat

        ## Signing Key / IDevID
        tpm2_nvdefine -C o -g sha256 -a "policywrite|writeall|ppread|ownerread|authread|policyread|no_da" -L secret_eh.policy -s 34 0x01c90010
        ## Set the "written" attribute
        tpm2_startauthsession -S session.ctx -g sha256 --policy-session
        tpm2_policysecret -S session.ctx -c e
        tpm2_nvwrite -P session:session.ctx -i zeros-34.dat 0x01c90010
        tpm2_flushcontext session.ctx
        tpm2_nvreadpublic 0x01c90010


    ## Signing Key / IDevID
    ## Policy hash (SHA256): 629c50b05f1adb5b4297feb241549d4217a1c792c162feb861022def88fa9501
    tpm2_startauthsession -S session.ctx -g sha256
    tpm2_policyauthorizenv -S session.ctx -L authorize_nv_idevid.policy 0x01c90010
    tpm2_flushcontext session.ctx


    ## Signing Key / IDevID
    tpm2_startauthsession -S session.ctx -g sha256
    tpm2_policyor -S session.ctx -L idevid.policy sha256:secret_eh.policy,secret_eh+command_certify.policy,secret_eh+command_activatecredential.policy,authorize_nv_idevid.policy
    tpm2_flushcontext session.ctx



# 7.3.1 Recoverable IDevID/IAK Key
echo 0001494445564944 | xxd -r -p > idevid.unique
tpm2_createprimary -C e -g sha256 -G rsa2048:rsassa:null -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|adminwithpolicy|sign" -L idevid.policy -u idevid.unique -c idevid.ctx


# TCG TPM v2.0 Provisioning Guidance (Version 1.0, Revision 1.0, March 15, 2017)
#   7.8 NV Memory
#     Table 2: Reserved Handles for TPM Provisioning Fundamental Elements
#       IDevID Key: 0x81020000
tpm2_evictcontrol -C o -c idevid.ctx 0x81020000

tpm2_flushcontext -t

# Output the TPMT_PUBLIC struct
# tpm2_readpublic -c 0x81020000 -f tpmt -o idevid.public.tpmt

# Output the public pem file
tpm2_readpublic -c 0x81020000 -f pem -o idevid.public.pem