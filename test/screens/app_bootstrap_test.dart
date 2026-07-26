import 'package:flutter_test/flutter_test.dart';
import 'package:piano/app.dart';
import 'package:piano/libs/note_mapper.dart';
import 'package:piano/screens/audio_failure_screen.dart';
import 'package:piano/libs/settings/piano_settings.dart';
import 'package:piano/screens/piano_screen.dart';

import '../helpers/fake_audio_engine.dart';
import '../helpers/fake_key_haptics.dart';
import '../helpers/fake_settings_store.dart';

void main() {
  testWidgets('failed engine init shows the failure screen', (tester) async {
    await tester.pumpWidget(PianoApp(
      engine: FakeAudioEngine(failInit: true),
      haptics: FakeKeyHaptics(),
      settingsStore: FakeSettingsStore(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(AudioFailureScreen), findsOneWidget);
    expect(find.text('Sound unavailable'), findsOneWidget);
  });

  testWidgets('failed sample load shows the failure screen', (tester) async {
    await tester.pumpWidget(PianoApp(
      engine: FakeAudioEngine(failLoad: true),
      haptics: FakeKeyHaptics(),
      settingsStore: FakeSettingsStore(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(AudioFailureScreen), findsOneWidget);
  });

  testWidgets('successful init loads all 30 samples and shows the keyboard',
      (tester) async {
    final engine = FakeAudioEngine();
    await tester.pumpWidget(PianoApp(engine: engine, haptics: FakeKeyHaptics(), settingsStore: FakeSettingsStore()));
    await tester.pumpAndSettle();
    expect(engine.loaded, NoteMapper.sampleAssetPaths);
    expect(find.byType(PianoScreen), findsOneWidget);
  });

  testWidgets('bootstrap hands persisted settings to the screen', (tester) async {
    final store = FakeSettingsStore(
        const PianoSettings(labelsOn: false, sizeStep: 0));
    await tester.pumpWidget(PianoApp(
      engine: FakeAudioEngine(),
      haptics: FakeKeyHaptics(),
      settingsStore: store,
    ));
    await tester.pumpAndSettle();
    final screen = tester.widget<PianoScreen>(find.byType(PianoScreen));
    expect(screen.initialSettings.labelsOn, isFalse);
    expect(screen.initialSettings.sizeStep, 0);
  });
}
