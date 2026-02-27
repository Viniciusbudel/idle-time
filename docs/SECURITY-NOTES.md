# Security Notes

Last updated: 2026-02-27

## Storage Policy

- `shared_preferences` is used for non-secret local game state (progress/save data).
- Do not store credentials, access tokens, API secrets, or private keys in `shared_preferences`.
- Any future secret material must be handled by backend-issued short-lived tokens and secure platform storage patterns.

## Android Exported Activity

- `android:exported="true"` in `android/app/src/main/AndroidManifest.xml` is expected for the launcher `MainActivity` that defines `MAIN` + `LAUNCHER` intent filters.
- This setting is required for modern Android builds in this context and is not treated as a vulnerability by itself.

## Randomness Usage

- `dart:math.Random()` is acceptable for gameplay visuals, animations, and non-security game mechanics.
- `Random()` must not be used for security-sensitive values (tokens, auth/session identifiers, nonces, secrets, signatures, cryptographic keys).
- If security-sensitive randomness is ever needed, use cryptographically secure generation.

## Logging Policy

- App logs should be routed through `AppLog` and remain debug-only in release builds.
- Do not log PII, secrets, tokens, credentials, or full payloads from external sources.
- Prefer redacted summaries over raw payload logging.

## New Feature Security Checklist

- No hardcoded secrets/tokens in code or configs.
- No production HTTP endpoints; use HTTPS.
- No TLS bypass patterns (for example, `badCertificateCallback` in production paths).
- No sensitive logs in release builds.
- Any exposed platform components must have explicit rationale and constraints.

