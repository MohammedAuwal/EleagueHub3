# EleagueHub (Android Flutter)

MVP foundation with:
- Mock auth shell
- Bottom navigation: Home, Leagues, Live, Marketplace, Profile
- Glassmorphism UI + animated bubble background
- Theme auto-detect + instant toggle + persistence
- Mock modules + repositories (offline)

## Build in GitHub Actions
Workflow builds:
- `flutter analyze`
- `flutter test`
- Debug APK
- Release AAB (unsigned by default; optional signing via secrets)

## Optional Android Release Signing (GitHub Secrets)
If you add these secrets, the workflow will sign the release AAB:
- `ANDROID_KEYSTORE_BASE64` (base64 of your `.jks`)
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

### How to create base64
On your computer (or any environment with base64):
```bash
base64 -w 0 your-keystore.jks > keystore.b64.txt
```
# EleagueHub3
