import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piano/screens/audio_failure_screen.dart';
import 'package:piano/screens/boot_screen.dart';
import 'package:piano/screens/piano_screen.dart';

import '../helpers/fake_audio_engine.dart';
import '../helpers/fake_key_haptics.dart';
import '../helpers/pump_localized.dart';

Future<void> _pumpPianoScreen(WidgetTester tester, Locale locale) =>
    pumpLocalized(
      tester,
      PianoScreen(engine: FakeAudioEngine(), haptics: FakeKeyHaptics()),
      locale: locale,
    );

/// Every state the user can land on, in every shipped locale, must pass the Material
/// accessibility guidelines. A new screen that is not registered here is the failure
/// this suite exists to prevent — keep the map exhaustive.
final _screenStates = <String, Future<void> Function(WidgetTester, Locale)>{
  'boot screen': (tester, locale) =>
      pumpLocalized(tester, const BootScreen(), locale: locale),
  'piano (labels on)': _pumpPianoScreen,
  'piano (labels off)': (tester, locale) async {
    await _pumpPianoScreen(tester, locale);
    await tester.tap(find.byIcon(Icons.abc));
    await tester.pumpAndSettle();
  },
  'piano (bigger keys)': (tester, locale) async {
    await _pumpPianoScreen(tester, locale);
    await tester.ensureVisible(find.byIcon(Icons.zoom_in));
    await tester.tap(find.byIcon(Icons.zoom_in));
    await tester.pumpAndSettle();
  },
  'piano (smaller keys)': (tester, locale) async {
    await _pumpPianoScreen(tester, locale);
    await tester.ensureVisible(find.byIcon(Icons.zoom_out));
    await tester.tap(find.byIcon(Icons.zoom_out));
    await tester.pumpAndSettle();
  },
  'piano (sustain on)': (tester, locale) async {
    await _pumpPianoScreen(tester, locale);
    await tester.tap(find.byIcon(Icons.all_inclusive));
    await tester.pumpAndSettle();
  },
  'audio failure': (tester, locale) =>
      pumpLocalized(tester, AudioFailureScreen(onRetry: () {}), locale: locale),
};

void main() {
  for (final locale in const [Locale('en'), Locale('fr')]) {
    for (final state in _screenStates.entries) {
      testWidgets('${state.key} (${locale.languageCode}) meets a11y guidelines',
          (tester) async {
        final handle = tester.ensureSemantics();
        await state.value(tester, locale);

        // Small-key density is an explicit user opt-in (Ivan, 2026-07-26):
        // black keys drop below 48dp by design there — every other state
        // keeps the full tap-target gate, and labels + contrast always apply.
        if (state.key != 'piano (smaller keys)') {
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        }
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
      });
    }
  }
}
