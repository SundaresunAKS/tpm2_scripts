
#!/usr/bin/env bash

# -e: exit when any command fails
# -x: all executed commands are printed to the terminal
# -o pipefail: prevents errors in a pipeline from being masked
#set -exo pipefail

####################################################
# Create Endorsement Key (RSA) & Read out the EK certificate
####################################################
tpm2_createek -c 0x81010001 -G rsa -u rsa_ek.public.pem -f pem
openssl pkey -inform PEM -pubin -in rsa_ek.public.pem -text

tpm2_nvread 0x1c00002 -o rsa_ek.crt.der
openssl x509 -inform der -in rsa_ek.crt.der -out rsa_ek.crt.pem
openssl x509 -inform der -in rsa_ek.crt.der -text

echo "script Complete...."