
# Digital Signature (RSA and DSA Approach) using openssl cmds.


# (1) RSA Keys:

echo testMsg > myfile.txt
openssl genrsa -out rsaKey_Private.pem 1024
openssl rsa -in rsaKey_Private.pem -pubout > rsaKey_Public.pem

openssl dgst -sha256 -sign rsaKey_Private.pem -out rsaSign.sign myfile.txt
hexdump rsaSign.sign

openssl dgst -sha256 -verify rsaKey_Public.pem -signature rsaSign.sign myfile.txt
openssl rsa -in rsaKey_Private.pem -text

# ----------------XXXXX----------------

# (2) DSA Keys:

echo testMsg > msg.txt
openssl dsaparam -out dsaparam.pem 1024
openssl gendsa -out dsaKey_Private.pem dsaparam.pem
openssl dsa -in dsaKey_Private.pem -pubout > dsaKey_public.pem

openssl dgst -sha256 -sign dsaKey_Private.pem -out dsaSign.sig msg.txt
hexdump dsaSign.sign

openssl dgst -sha256 -verify dsaKey_public.pem -signature dsaSign.sig msg.txt
openssl dsa -in dsaKey_Private.pem -text
