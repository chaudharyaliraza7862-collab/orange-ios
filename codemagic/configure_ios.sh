#!/usr/bin/env bash
set -euo pipefail

cd "${CM_BUILD_DIR:-$(pwd)}"

: "${API_BASE_URL:=https://orange-app-backend.blockchaintestin.workers.dev/}"
: "${BUNDLE_ID:=com.blockchaintestin.orangeapp}"
: "${IOS_DISTRIBUTION:=0}"
: "${REQUIRE_FIREBASE_IOS:=0}"

if [[ "$API_BASE_URL" != */ ]]; then
  API_BASE_URL="${API_BASE_URL}/"
fi
export API_BASE_URL BUNDLE_ID IOS_DISTRIBUTION REQUIRE_FIREBASE_IOS

if [[ -n "${GOOGLE_SERVICE_INFO_PLIST_BASE64:-}" ]]; then
  echo "$GOOGLE_SERVICE_INFO_PLIST_BASE64" | base64 --decode > ios/Runner/GoogleService-Info.plist
  echo "Installed GoogleService-Info.plist from Codemagic secret."
elif [[ "$REQUIRE_FIREBASE_IOS" == "1" ]]; then
  echo "ERROR: GOOGLE_SERVICE_INFO_PLIST_BASE64 is required for the signed iOS workflow."
  exit 1
else
  echo "Compile-check workflow: using the repository's existing Firebase plist if present."
fi

python3 codemagic/configure_ios.py
