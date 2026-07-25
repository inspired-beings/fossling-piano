# Fossling <Function>

<!-- Bootstrapping a new app: rename this file to AGENTS.md, run `ln -s AGENTS.md CLAUDE.md`, fill every <placeholder>, delete this comment. -->

Flutter Android app: <one line — what it does, for whom>. applicationId `com.fossling.<app>`.

## Toolchain

mise-managed: `mise install`, then `eval "$(mise activate bash)"`. Commands: `flutter analyze`, `flutter test`, `flutter gen-l10n`, `adb devices && flutter run` (real device, no emulator).

## Architecture

- Feature-based: `lib/screens/`, `lib/features/*/components/`; one class/function per file; types in `types.dart`, constants in `constants.dart`.
- Hardware behind an abstraction with a fake for tests (`<Abstraction>` / `Fake<Abstraction>`) — no device/plugin access in unit tests.
- App theme from `lib/libs/build_app_theme.dart`, shared with the a11y tests — never inline theme colors.
- L10n: source `.arb` in `lib/l10n/` (en + fr), generated output gitignored.

## Gates (CI-enforced — thresholds only loosen by product-owner decision)

- Accessibility: EVERY reachable screen state is registered in `test/a11y/accessibility_guidelines_test.dart` (× en/fr) and survives `test/a11y/text_scaling_test.dart`.
- Sustainable design: `tool/check_release_apk.sh` runs on the built release APK — size budget (ratchet-down-only), forbidden merged-manifest permissions (strip unwanted ones with `tools:node="remove"`), minSdk ≤ 26.
- Security: `tool/check_security_alerts.sh` — any open code-scanning/secret-scanning/Dependabot alert blocks PRs and `v*` releases.

## Store metadata

`fastlane/metadata/android/` (en-US + fr-FR) is the source of truth; en-US `full_description.txt` is the master and `README.md` mirrors it — a PR touching one updates the other. Changelogs keyed by versionCode.

## Git

Conventional Commits (Angular); every commit signed off (`git commit -s`, DCO-gated); squash-merge only.
