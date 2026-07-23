# Android release signing

Release builds are signed with a private upload keystore, **not** the debug
key (a debug-signed APK is rejected by Google Play and lets anyone ship a
same-signature update).

## Files (both are gitignored — never commit them)
- `app/vault-release.jks` — the keystore.
- `key.properties` — passwords + alias, loaded by `app/build.gradle.kts`.

`key.properties` format:
```
storePassword=…
keyPassword=…
keyAlias=vault
storeFile=vault-release.jks
```

`build.gradle.kts` uses the release keystore when `key.properties` exists and
falls back to debug signing only for local dev without it, so `flutter run`
still works on a fresh checkout.

## ⚠️ For a real Google Play release
1. The keystore in this repo was generated for development. **Generate your own**
   and keep it (plus `key.properties`) somewhere safe & backed up — losing it
   means you can never update the app on Play.
   ```
   keytool -genkeypair -v -keystore app/vault-release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias vault
   ```
2. Prefer **Play App Signing**: upload with your upload key; Google manages the
   final signing key.
3. Store passwords in CI secrets, not on disk, for automated builds.

## Build
```
flutter build appbundle --release   # .aab for Play
flutter build apk --release          # .apk for sideload/testing
```
