#!/bin/bash

set -e

LOWERCASE_USERNAME=$(echo "$ZOWE_USERNAME" | tr '[:upper:]' '[:lower:]')

USS_DIR="/z/$LOWERCASE_USERNAME/cobolcheck"

ZOWE_CONNECTION=(
  --host "$ZOWE_HOST"
  --port "$ZOWE_PORT"
  --user "$ZOWE_USERNAME"
  --password "$ZOWE_PASSWORD"
  --reject-unauthorized false
)

echo "Using USS directory: $USS_DIR"

# Check whether directory exists
if ! zowe zos-files list uss-files "$USS_DIR" "${ZOWE_CONNECTION[@]}" > /dev/null 2>&1; then

  echo "Directory does not exist. Creating it..."

  zowe zos-files create uss-directory "$USS_DIR" \
    "${ZOWE_CONNECTION[@]}"

else
  echo "Directory already exists."
fi

# Upload COBOL Check
echo "Uploading COBOL Check..."

zowe zos-files upload dir-to-uss \
  "./cobol-check" \
  "$USS_DIR" \
  --recursive \
  --binary-files "cobol-check-0.2.9.jar" \
  "${ZOWE_CONNECTION[@]}"

# Verify upload
echo "Verifying upload..."

zowe zos-files list uss-files "$USS_DIR" \
  "${ZOWE_CONNECTION[@]}"

echo "COBOL Check upload completed successfully."
