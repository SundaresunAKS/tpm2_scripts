
# Simple TPM Lockout Procedure

Step 1:
   * Run the "lockOutTest.sh" using:
        ```
        sh lockOutTest.sh
        ```

Step 2:
   * Next, run "lockOutLoop.sh" (this will put the TPM into LockOut mode) using:
        ```
        sh lockOutLoop.sh
        ```
   * After entering the TPM into LockOut mode, we won't be able to sign the data even if the correct password is provided.
        Note: The duration and the number of attempts before the TPM enters lockout mode are configurable. [Link here](https://github.com/tpm2-software/tpm2-tools/blob/5.7.X/man/tpm2_dictionarylockout.1.md).