# Fossling Piano

Flutter Android app: piano keyboard with sampled grand-piano sound, accessibility-first (TalkBack play mode, haptics, large keys). applicationId `com.fossling.piano`.

## Toolchain

mise-managed: `mise install`, then `eval "$(mise activate bash)"`. Commands: `flutter analyze`, `flutter test`, `flutter gen-l10n`, `adb devices && flutter run` (real device, no emulator).

## Architecture

- Feature-based: `lib/screens/`, `lib/features/*/components/`; one class/function per file; types in `types.dart`, constants in `constants.dart`.
- Pure-Dart core, fully unit-tested: `NoteMapper` (note → sample + pitch factor, ±1 semitone max), `KeyboardLayout` (viewport geometry incl. clipped edge blacks, 48dp black-key floor), `PointerTracker` (multi-touch + glissando).
- Hardware behind abstractions with fakes for tests: `AudioEngine` / `SoLoudAudioEngine` (`flutter_soloud`, swappable — Oboe FFI is the QA-gated latency fallback) / `FakeAudioEngine`, and `KeyHaptics` / `FakeKeyHaptics`. No device/plugin access in unit tests.
- Samples: 30 Ogg files in `assets/samples/` (Salamander Grand Piano, CC BY 3.0 — attribution in `NOTICE`, provenance in `assets/samples/PROVENANCE.md`, rebuilt only via `tool/prepare_samples.sh`).
- App theme from `lib/libs/build_app_theme.dart`, shared with the a11y tests — never inline theme colors.
- L10n: source `.arb` in `lib/l10n/` (en + fr), generated output gitignored. Note names and key semantics are locale-aware (C/do); octave shifts send a screen-reader announcement.

## Gates (CI-enforced — thresholds only loosen by product-owner decision)

- Accessibility: EVERY reachable screen state is registered in `test/a11y/accessibility_guidelines_test.dart` (× en/fr) and survives `test/a11y/text_scaling_test.dart`. Every key target ≥48dp on any screen width — geometry adapts, the gate never loosens.
- Sustainable design: `tool/check_release_apk.sh` runs on the built release APK — size budget 61 MiB (ratchet-down-only), forbidden merged-manifest permissions (this app ships with ZERO permissions; strip anything a plugin merges with `tools:node="remove"`), minSdk ≤ 26.
- Security: `tool/check_security_alerts.sh` — any open code-scanning/secret-scanning/Dependabot alert blocks PRs and `v*` releases.

## Store metadata

`fastlane/metadata/android/` (en-US + fr-FR) is the source of truth; en-US `full_description.txt` is the master and `README.md` mirrors it — a PR touching one updates the other. Changelogs keyed by versionCode. The Salamander CC BY attribution must stay in README, NOTICE, and both full descriptions.

## Git

Conventional Commits (Angular); every commit signed off (`git commit -s`, DCO-gated); squash-merge only.
