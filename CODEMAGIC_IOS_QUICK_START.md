# Orange iOS — Fast Codemagic Setup

This pack does **not change any Flutter UI/front-end screens**. It only adds cloud-build configuration for iOS.

## 1. Put this pack in the Flutter project root

Extract these files directly into:

`C:\Users\DELL\Downloads\orange\flutter`

After extraction you should have:

- `C:\Users\DELL\Downloads\orange\flutter\codemagic.yaml`
- `C:\Users\DELL\Downloads\orange\flutter\codemagic\configure_ios.sh`
- `C:\Users\DELL\Downloads\orange\flutter\codemagic\configure_ios.py`

## 2. Use a PRIVATE GitHub repository

Create an empty **private** GitHub repository, for example `orange-ios`.

Then double-click `PUSH_TO_GITHUB.cmd` from the Flutter folder and paste the repository URL when asked.

The repository root must be the Flutter folder. `codemagic.yaml` must sit beside `pubspec.yaml`.

## 3. First run: compile check (no Apple account required)

In Codemagic:

1. Add application.
2. Connect the private GitHub repository.
3. Select `codemagic.yaml` configuration.
4. Run workflow **Orange iOS - Compile Check (No Apple account required)**.

This verifies that the iOS source compiles on a real macOS/Xcode build machine. It produces an unsigned `.app` ZIP. It cannot be installed on an ordinary iPhone because Apple requires signing.

## 4. To get a real IPA/TestFlight build

You need an active Apple Developer Program membership. You do not need to own a Mac.

The prepared production bundle identifier is:

`com.blockchaintestin.orangeapp`

In Apple Developer, register this App ID. For the current Orange source, enable at least:

- Push Notifications
- Sign in with Apple

Associated Domains are automatically removed from the build until you provide real domains.

Then create the matching app in App Store Connect using the same bundle identifier.

## 5. Add Apple credentials to Codemagic

Create a Codemagic variable group named **appstore_credentials** with these secret variables:

- `APP_STORE_CONNECT_PRIVATE_KEY` — complete contents of your App Store Connect `.p8` API key
- `APP_STORE_CONNECT_KEY_IDENTIFIER` — Apple Key ID
- `APP_STORE_CONNECT_ISSUER_ID` — Apple Issuer ID

The App Store Connect API key should have **App Manager** access.

In Codemagic Code signing identities, add/generate an **Apple Distribution** certificate and fetch/create an **App Store** provisioning profile for:

`com.blockchaintestin.orangeapp`

## 6. Add Orange iOS service variables

Create another Codemagic group named **orange_ios**.

Required:

- `GOOGLE_SERVICE_INFO_PLIST_BASE64` — your Firebase iOS `GoogleService-Info.plist`, converted to Base64

Optional but needed for the respective features:

- `GOOGLE_MAPS_IOS_API_KEY`
- `AGORA_APP_ID`
- `REVENUECAT_IOS_PUBLIC_KEY`
- `ASSOCIATED_DOMAINS` — comma-separated domains, e.g. `app.example.com,www.example.com`

The Cloudflare API URL is already configured as:

`https://orange-app-backend.blockchaintestin.workers.dev/`

### Convert Firebase plist to Base64 on Windows

Put your new Firebase `GoogleService-Info.plist` somewhere on the PC and run `COPY_FIREBASE_PLIST_BASE64.cmd`. Paste its path. The Base64 value is copied to your Windows clipboard; paste that value into the Codemagic variable.

Important: the Firebase iOS app must use bundle ID `com.blockchaintestin.orangeapp`.

## 7. Build and send to TestFlight

Run workflow:

**Orange iOS - Signed IPA + TestFlight**

The workflow will:

1. Configure the iOS bundle ID.
2. Inject your Firebase plist securely.
3. Install Flutter packages and CocoaPods.
4. Apply the Apple signing profile.
5. Build a signed `.ipa`.
6. Upload it to App Store Connect/TestFlight automatically.

The signed IPA is also kept as a Codemagic artifact under `build/ios/ipa/*.ipa`.

## Important

- Direct public `.ipa` downloading is not the normal Apple distribution method. Use TestFlight during testing and an App Store link for public users.
- Agora and RevenueCat were optional in the Android test build as well. Add their iOS public keys when you want those functions live.
- The original project contains Firebase/Google configuration from the previous developer. For production, use your own Firebase iOS app and Google Maps key.
