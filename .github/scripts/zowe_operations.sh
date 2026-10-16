#!/bin/bash

set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

USS_DIR="/z/$LOWERCASE_USERNAME/cobolcheck"

# Configure Zowe connection
export ZOWE_OPT_HOST="$ZOWE_HOST"
export ZOWE_OPT_PORT="$ZOWE_PORT"
export ZOWE_OPT_USER="$ZOWE_USERNAME"
export ZOWE_OPT_PASSWORD="$ZOWE_PASSWORD"
export ZOWE_OPT_REJECT_UNAUTHORIZED="false"

echo "Using USS directory: $USS_DIR"

# Check whether USS directory exists
if ! zowe zos-files list uss-files "$USS_DIR" > /dev/null 2>&1; then

  echo "Directory does not exist. Creating it..."

  zowe zos-files create uss-directory "$USS_DIR"

else
  echo "Directory already exists."
fi

# Upload COBOL Check
echo "Uploading COBOL Check..."

zowe zos-files upload dir-to-uss \
  "./cobol-check" \
  "$USS_DIR" \
  --recursive \
  --binary-files "cobol-check-0.2.19.jar"

# Upload NUMBERS.JCL for Lab 1
echo "Uploading NUMBERS.JCL..."

zowe zos-files upload file-to-uss \
  "./NUMBERS.JCL" \
  "$USS_DIR/NUMBERS.JCL"

# Upload EMPPAY.JCL for Lab 2
echo "Uploading EMPPAY.JCL..."

zowe zos-files upload file-to-uss \
  "./EMPPAY.JCL" \
  "$USS_DIR/EMPPAY.JCL"  

# Upload script that will run on USS
echo "Uploading mainframe_operations.sh..."

zowe zos-files upload file-to-uss \
  ".github/scripts/mainframe_operations.sh" \
  "$USS_DIR/mainframe_operations.sh"

# Verify upload
echo "Verifying upload..."

zowe zos-files list uss-files "$USS_DIR"

echo "COBOL Check upload completed successfully."
