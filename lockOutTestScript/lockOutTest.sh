
sudo tpm2_clear -c p

sudo tpm2_changeauth -c l passLockOut

sudo tpm2_dictionarylockout -c -p passLockOut

# // Change Owner Hirarkiya Passwords
sudo tpm2_changeauth -c o passBindAuth

# // Create SRK with password
sudo tpm2_createprimary -C o -g sha256 -G rsa2048:null:aes128cfb -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|noda|restricted|decrypt" -c srk.ctx -p srkpassword -P passBindAuth

# // Store the SRK
sudo tpm2_evictcontrol -C o -c srk.ctx 0x81000001 -P passBindAuth

# // Delete All the temp objects
sudo tpm2_flushcontext \--transient-object

# // Create LdevID with password
sudo tpm2_create -C 0x81000001 -g sha256 -G rsa2048:null:null -a "fixedtpm|fixedparent|sensitivedataorigin|userwithauth|decrypt|sign" -u ldevid.public -r ldevid.private -p ldevidpassword -P srkpassword

sudo tpm2_load -C 0x81000001 -u ldevid.public -r ldevid.private -c ldevid.ctx -P srkpassword

sudo tpm2_evictcontrol -C o -c ldevid.ctx 0x81000003 -P passBindAuth

sudo echo "userData_or_info" > message.dat
sudo sha256sum message.dat | awk '{ print "000000 " $1 }' | xxd -r -c 32 > message.in.digest
sudo tpm2_sign -c 0x81000003 -g sha256 -d -f plain -o sig.rssa message.in.digest -p ldevidpassword