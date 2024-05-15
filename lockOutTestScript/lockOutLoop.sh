#/bin/bash
a=0
while [ $a -lt 32 ]

do

echo "Test: " $a
sudo tpm2_sign -c 0x81000003 -g sha256 -d -f plain -o sig.rssa message.in.digest -p ldevidpassword123
# sudo tpm2_evictcontrol -C o -c 0x81000003 -P passBindAuth112

a=`expr $a + 1`
done