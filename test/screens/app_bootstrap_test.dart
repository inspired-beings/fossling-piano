import 'package:flutter_test/flutter_test.dart';
import 'package:piano/app.dart';
import 'package:piano/libs/note_mapper.dart';
import 'package:piano/screens/audio_failure_screen.dart';
import 'package:piano/screens/piano_screen.dart';

import '../helpers/fake_audio_engine.dart';
import '../helpers/fake_key_haptics.dart';

void main() {
  testWidgets('failed engine init shows the failure screen', (tester) async {
    await tester.pumpWidget(PianoApp(
      engine: FakeAudioEngine(failInit: true),
      haptics: FakeKeyHaptics(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(AudioFailureScreen), findsOneWidget);
    expect(find.text('Sound unavailable'), findsOneWidget);
  });

  testWidgets('failed sample load shows the failure screen', (tester) async {
    await tester.pumpWidget(PianoApp(
      engine: FakeAudioEngine(failLoad: true),
      haptics: FakeKeyHaptics(),
    ));
    await tester.pumpAndSettle();
    expect(find.byType(AudioFailureScreen), findsOneWidget);
  });

  testWidgets('successful init loads all 30 samples and shows the keyboard',
      (tester) async {
    final engine = FakeAudioEngine();
    await tester.pumpWidget(PianoApp(engine: engine, haptics: FakeKeyHaptics()));
    await tester.pumpAndSettle();
    expect(engine.loaded, NoteMapper.sampleAssetPaths);
    expect(find.byType(PianoScreen), findsOneWidget);
  });
}
