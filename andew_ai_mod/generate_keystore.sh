#!/bin/bash
# Script to generate keystore for signing APK
# Run this ONCE locally, then add the base64 to GitHub Secrets

set -e

KEYSTORE_FILE="andew_ai.keystore"
ALIAS="andew_ai"
STORE_PASS="andewai123"
KEY_PASS="andewai123"
VALIDITY=10000
DNAME="CN=Andew AI, OU=Development, O=Andew AI, L=City, ST=State, C=US"

echo "Generating keystore: $KEYSTORE_FILE"
echo "Alias: $ALIAS"
echo "Store Password: $STORE_PASS"
echo "Key Password: $KEY_PASS"
echo "Validity: $VALIDITY days"
echo "DName: $DNAME"
echo

# Check if keystore already exists
if [ -f "$KEYSTORE_FILE" ]; then
    echo "Keystore already exists. Backing up..."
    mv "$KEYSTORE_FILE" "${KEYSTORE_FILE}.backup.$(date +%s)"
fi

# Generate keystore
keytool -genkeypair \
    -alias "$ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity "$VALIDITY" \
    -keystore "$KEYSTORE_FILE" \
    -storepass "$STORE_PASS" \
    -keypass "$KEY_PASS" \
    -dname "$DNAME" \
    -noprompt

echo
echo "✅ Keystore generated successfully!"
echo "File: $KEYSTORE_FILE"
echo "Size: $(ls -lh "$KEYSTORE_FILE" | awk '{print $5}')"
echo

# Convert to base64 for GitHub Secrets
echo "=== COPY THIS BASE64 STRING TO GITHUB SECRETS ==="
echo "Secret Name: KEYSTORE_BASE64"
echo "Value:"
base64 -w 0 "$KEYSTORE_FILE"
echo
echo

# Also show the passwords to add as secrets
echo "=== ADD THESE AS GITHUB SECRETS TOO ==="
echo "Secret Name: KEYSTORE_PASSWORD"
echo "Value: $STORE_PASS"
echo
echo "Secret Name: KEY_PASSWORD"
echo "Value: $KEY_PASS"
echo

# Verify keystore
echo "=== VERIFICATION ==="
keytool -list -v -keystore "$KEYSTORE_FILE" -storepass "$STORE_PASS" -alias "$ALIAS"