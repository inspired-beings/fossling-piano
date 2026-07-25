import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piano/screens/audio_failure_screen.dart';
import 'package:piano/screens/boot_screen.dart';
import 'package:piano/screens/piano_screen.dart';

import '../helpers/fake_audio_engine.dart';
import '../helpers/fake_key_haptics.dart';
import '../helpers/pump_localized.dart';

/// Android's font-size setting goes to 2.0x — the UI must survive it on the
/// smallest screen we support. Layout overflow reports fail the test on their
/// own; the expectations below additionally pin that the controls are still
/// reachable rather than merely not crashing.
void main() {
  const smallScreen = Size(320, 568);
  const scalers = [1.0, 1.3, 2.0];

  for (final scale in scalers) {
    testWidgets('boot screen survives a ${scale}x font scale', (tester) async {
      tester.view.physicalSize = smallScreen;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpLocalized(tester, const BootScreen(),
          textScaler: TextScaler.linear(scale));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('piano screen survives a ${scale}x font scale', (tester) async {
      tester.view.physicalSize = smallScreen;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpLocalized(
        tester,
        PianoScreen(engine: FakeAudioEngine(), haptics: FakeKeyHaptics()),
        textScaler: TextScaler.linear(scale),
      );

      expect(find.bySemanticsLabel('Octave down'), findsOneWidget);
      expect(find.bySemanticsLabel('Octave up'), findsOneWidget);
      expect(find.text('Labels'), findsOneWidget);
      expect(find.text('Sustain'), findsOneWidget);
      expect(find.text('Large keys'), findsOneWidget);
      expect(find.bySemanticsLabel('C 4, piano key'), findsOneWidget);
    });

    testWidgets('audio failure screen survives a ${scale}x font scale',
        (tester) async {
      tester.view.physicalSize = smallScreen;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpLocalized(tester, AudioFailureScreen(onRetry: () {}),
          textScaler: TextScaler.linear(scale));

      expect(find.text('Sound unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  }
}
