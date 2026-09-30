#!/usr/bin/env python3
import os
import plistlib
import re
from pathlib import Path

root = Path.cwd()
ios = root / "ios"
runner = ios / "Runner"
pbx = ios / "Runner.xcodeproj" / "project.pbxproj"
info_path = runner / "Info.plist"
google_path = runner / "GoogleService-Info.plist"
ent_path = runner / "Runner.entitlements"
app_delegate = runner / "AppDelegate.swift"

bundle_id = os.environ.get("BUNDLE_ID", "com.blockchaintestin.orangeapp").strip()
api_base = os.environ.get("API_BASE_URL", "https://orange-app-backend.blockchaintestin.workers.dev/").strip()
ios_distribution = os.environ.get("IOS_DISTRIBUTION", "0") == "1"
associated_domains = [x.strip() for x in os.environ.get("ASSOCIATED_DOMAINS", "").split(",") if x.strip()]
map_key = os.environ.get("GOOGLE_MAPS_IOS_API_KEY", "").strip()

if not re.fullmatch(r"[A-Za-z0-9.-]+", bundle_id) or "." not in bundle_id:
    raise SystemExit(f"Invalid BUNDLE_ID: {bundle_id}")

# Replace the previous developer's bundle identifier and remove their fixed team ID.
text = pbx.read_text(encoding="utf-8")
text = re.sub(r"PRODUCT_BUNDLE_IDENTIFIER = [^;]+;", f"PRODUCT_BUNDLE_IDENTIFIER = {bundle_id};", text)
text = re.sub(r"\n\s*DEVELOPMENT_TEAM = [A-Z0-9]+;", "", text)
pbx.write_text(text, encoding="utf-8")

# Keep only valid associated domains. The source project contained placeholder domains.
if ent_path.exists():
    with ent_path.open("rb") as f:
        ent = plistlib.load(f)
    if associated_domains:
        normalized = [d if d.startswith("applinks:") else f"applinks:{d}" for d in associated_domains]
        ent["com.apple.developer.associated-domains"] = normalized
    else:
        ent.pop("com.apple.developer.associated-domains", None)
    if "aps-environment" in ent:
        ent["aps-environment"] = "production" if ios_distribution else "development"
    with ent_path.open("wb") as f:
        plistlib.dump(ent, f, sort_keys=False)

# If a Firebase plist is available, validate/patch Google sign-in values in Info.plist.
if google_path.exists():
    with google_path.open("rb") as f:
        google = plistlib.load(f)
    configured_bundle = str(google.get("BUNDLE_ID", ""))
    if configured_bundle and configured_bundle != bundle_id:
        print(f"WARNING: Firebase plist BUNDLE_ID is {configured_bundle}, build bundle ID is {bundle_id}.")
        print("Create/download a Firebase iOS app for the new bundle ID before production use.")
    client_id = str(google.get("CLIENT_ID", ""))
    reversed_client_id = str(google.get("REVERSED_CLIENT_ID", ""))
    with info_path.open("rb") as f:
        info = plistlib.load(f)
    if client_id:
        info["GIDClientID"] = client_id
    if reversed_client_id:
        url_types = info.setdefault("CFBundleURLTypes", [])
        google_entry = None
        for item in url_types:
            if item.get("CFBundleURLName") == "Google Sign in":
                google_entry = item
                break
        if google_entry is None:
            google_entry = {"CFBundleTypeRole": "Editor", "CFBundleURLName": "Google Sign in"}
            url_types.insert(0, google_entry)
        google_entry["CFBundleURLSchemes"] = [reversed_client_id]
    with info_path.open("wb") as f:
        plistlib.dump(info, f, sort_keys=False)

# Patch Google Maps only when a real key is supplied. Never write secrets to source control.
if map_key and app_delegate.exists():
    src = app_delegate.read_text(encoding="utf-8")
    src = re.sub(r'GMSServices\.provideAPIKey\("[^"]*"\)', f'GMSServices.provideAPIKey("{map_key}")', src)
    app_delegate.write_text(src, encoding="utf-8")

print("Orange iOS configuration prepared")
print(f"  Bundle ID: {bundle_id}")
print(f"  API: {api_base}")
print(f"  Distribution build: {ios_distribution}")
