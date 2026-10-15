#!/bin/bash

# Stop immediately if a command fails
set -e

# Convert username to lowercase
LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

USS_DIR="/z/$LOWERCASE_USERNAME/cobolcheck"

echo "Using USS directory: $USS_DIR"

# Check if directory exists
if ! zowe zos-files list uss-files "$USS_DIR" > /dev/null 2>&1; then
  echo "Directory does not exist. Creating it..."

  zowe zos-files create uss-directory "$USS_DIR"
else
  echo "Directory already exists."
fi

# Upload COBOL Check
echo "Uploading COBOL Check..."

zowe zos-files upload dir-to-uss "./cobol-check" "$USS_DIR" \
  --recursive \
  --binary-files "cobol-check-0.2.9.jar"

# Verify upload
echo "Verifying upload:"

zowe zos-files list uss-files "$USS_DIR"
