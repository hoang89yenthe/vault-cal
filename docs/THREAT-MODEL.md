# Vault Cal — Threat Model

*Last updated: 2026-07. This document describes what Vault Cal protects, what
it deliberately does **not** protect, and how. It is written to be verifiable
against the source code — every claim below maps to code in this repository.*

Vault Cal is a **local, offline** encrypted vault disguised as a calculator.
There is **no cloud, no account, no server, and no telemetry.** All data and
keys live only on the device.

---

## 1. Assets we protect

- **Vault contents at rest** — photos, videos, documents and notes the user
  imports, stored encrypted on disk.
- **The existence and contents of the *real* vault under coercion** — via a
  separate *decoy* vault that a duress PIN opens instead (plausible
  deniability). This is a *practical/social* protection, not a cryptographic
  guarantee — see §4.

## 2. Design & security properties

| Property | Mechanism |
|---|---|
| File encryption | AES-256-GCM, chunked (4 MiB), streamed in isolates. Per-file random data-encryption key (DEK). |
| Integrity / anti-tamper | Each chunk authenticated with GCM; the file header **and an authenticated total-chunk count** are fed as GCM AAD on every chunk → silent tail-truncation and header/version tampering are detected. |
| Key hierarchy | Per-namespace 32-byte random **master key** (separate for real vs decoy) stored in Android Keystore / iOS Keychain. DEKs are AES-GCM-wrapped by the master key; the SQLCipher DB key is HKDF-derived from it. |
| Metadata at rest | Encrypted **SQLCipher** database (file names, sizes, note bodies, intruder log). |
| Credentials | Secret code + real PIN + decoy PIN, hashed with **PBKDF2-HMAC-SHA256** (150k iterations, per-entry salt) in secure storage. No default/seeded codes — set by the user on first run. |
| Timing safety | PIN verification does **constant work** (always checks both real and decoy) so a coercer timing the unlock cannot distinguish a duress open from a real one. |
| Access control | Optional **biometric** gate (`local_auth`) that must pass before the PIN, then the PIN. |
| Brute-force resistance | **Persistent, escalating lockout** on wrong PINs, stored in secure storage (survives app restart). Optional intruder selfie after repeated failures. |
| At-rest hardening | Android `allowBackup=false`; iOS Keychain `afterFirstUnlockThisDeviceOnly` (keys excluded from backups and non-transferable to another device). |
| In-use hardening | Android `FLAG_SECURE` (blocks screenshots, screen recording, and the Recents thumbnail); iOS app-switcher privacy cover; vault **re-locks on background**; decrypted plaintext (in-memory thumbnails + temp files) is **purged on lock**. |
| Disguise | Presents as a working calculator; a user-chosen secret code opens the unlock flow. Optional alternate launcher icons (calculator / weather / compass). |

## 3. Adversaries in scope

| Adversary | Scenario | Primary protection |
|---|---|---|
| Opportunistic snoop | Picks up the unlocked phone | Calculator disguise + auto re-lock on background |
| Thief | Steals a **locked** device | Encryption + OS keystore + lockout |
| Coercer | Forces the user to unlock | Decoy vault (see limitations in §4) |
| Onlooker | Shoulder-surfs or screenshots | `FLAG_SECURE` / iOS privacy cover |
| Backup thief | Obtains a device backup | Keys are not in backups (ThisDeviceOnly / `allowBackup=false`) |
| File tamperer | Edits/truncates encrypted files | GCM authentication + chunk-count check |

## 4. NOT in scope — what we do **not** protect against

Honesty here matters more than any feature. Do **not** rely on Vault Cal for
protection it does not provide.

- **A compromised OS or a rooted/jailbroken device.** Encryption protects data
  *at rest on an uncompromised device*. While the vault is unlocked, the master
  key lives in the OS keystore and decrypted data is in memory; malware or an
  attacker running with the app's (or root's) privileges on a compromised
  device can read them. If the OS is owned, the vault is owned.
- **Seizure while unlocked.** If the device is taken while the vault is open,
  its contents are exposed. Fast re-lock on background reduces, but does not
  eliminate, this window.
- **Compelled disclosure of the *real* PIN.** The decoy protects you only if
  the adversary does not know — or cannot prove — that a real vault also
  exists. Forensic inspection can reveal that the app is a vault (bundle id,
  file layout) and that a **second encrypted namespace** exists on disk.
  Plausible deniability here is practical, **not cryptographically perfect**.
- **Key extraction from secure hardware.** Advanced forensic extraction of keys
  from a TEE/StrongBox/Secure Enclave is out of scope; we rely on the OS
  keystore's guarantees.
- **Weak PINs.** A 4-digit PIN has only 10,000 combinations. On-device guessing
  is blocked by escalating lockout, but the PIN gates *access* — it does **not**
  add meaningful entropy to the encryption key (the random master key does).
- **No recovery.** Forgetting your codes, or losing the device keystore
  (factory reset, certain OS migrations), makes the data **unrecoverable by
  design.** There is no backdoor and no reset.
- **iOS manual screenshots.** The app blocks the app-switcher snapshot, but iOS
  does not let apps fully block a user-initiated screenshot (Android
  `FLAG_SECURE` does).
- **Network adversaries.** None apply — the app makes no network requests — but
  this also means there is no cloud copy; data exists only on the device.
- **Independent audit.** As of this writing, Vault Cal has **not** undergone a
  third-party security audit. Treat all claims as self-reported until then.

## 5. Cryptographic summary

- **Symmetric:** AES-256-GCM (12-byte nonce = 8-byte random prefix ‖ 4-byte
  chunk index; never reused).
- **KDF (credentials):** PBKDF2-HMAC-SHA256, 150k iterations, 16-byte salt.
- **Key derivation (DB):** HKDF-SHA256 from the namespace master key.
- **Randomness:** `Random.secure()` / platform CSPRNG for keys, salts, nonces.
- **Key storage:** `flutter_secure_storage` → Android Keystore-backed
  EncryptedSharedPreferences / iOS Keychain (ThisDeviceOnly).

## 6. Verifying these claims

- The app is **open source**; every mechanism above is in this repository
  (`lib/core/security/`, `lib/core/session/`, `lib/core/storage/`,
  `lib/features/unlock/`).
- Unit tests cover the crypto round-trips, truncation detection, lockout, and
  credential logic (`test/core/security/`, `test/features/unlock/`).
- Reproducible builds and an independent audit are on the roadmap — see the
  repository README.

## 7. Reporting a vulnerability

Please report security issues privately to the maintainer (see the repository
contact) rather than opening a public issue. We aim to acknowledge within a few
days and to disclose fixes transparently in the changelog.
