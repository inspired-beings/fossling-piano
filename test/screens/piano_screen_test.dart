import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piano/screens/piano_screen.dart';

import '../helpers/fake_audio_engine.dart';
import '../helpers/fake_key_haptics.dart';
import '../helpers/pump_localized.dart';

void main() {
  late FakeAudioEngine engine;
  late FakeKeyHaptics haptics;

  setUp(() {
    engine = FakeAudioEngine();
    haptics = FakeKeyHaptics();
  });

  Future<void> pumpScreen(WidgetTester tester, {Locale locale = const Locale('en')}) =>
      pumpLocalized(tester, PianoScreen(engine: engine, haptics: haptics),
          locale: locale);

  Offset keyCenter(WidgetTester tester, String semanticsLabel) =>
      tester.getCenter(find.bySemanticsLabel(semanticsLabel));

  testWidgets('key press plays mapped sample and haptic', (tester) async {
    await pumpScreen(tester);
    final gesture = await tester.startGesture(keyCenter(tester, 'C 4, piano key'));
    await tester.pump();
    expect(engine.played.single.assetPath, 'assets/samples/m60.ogg');
    expect(haptics.pressed, [60]);
    await gesture.up();
  });

  testWidgets('release without sustain fades the voice', (tester) async {
    await pumpScreen(tester);
    final gesture = await tester.startGesture(keyCenter(tester, 'C 4, piano key'));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(engine.released.single.sustain, isFalse);
  });

  testWidgets('release with sustain lets the note ring', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Sustain'));
    await tester.pump();
    final gesture = await tester.startGesture(keyCenter(tester, 'C 4, piano key'));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(engine.released.single.sustain, isTrue);
  });

  testWidgets('glissando releases old note and starts new one', (tester) async {
    await pumpScreen(tester);
    final gesture = await tester.startGesture(keyCenter(tester, 'C 4, piano key'));
    await tester.pump();
    await gesture.moveTo(keyCenter(tester, 'D 4, piano key'));
    await tester.pump();
    expect(engine.played.map((p) => p.assetPath).toList(),
        ['assets/samples/m60.ogg', 'assets/samples/m63.ogg']);
    expect(engine.released, hasLength(1));
    await gesture.up();
  });

  testWidgets('two simultaneous gestures play a chord', (tester) async {
    await pumpScreen(tester);
    final first = await tester.startGesture(keyCenter(tester, 'C 4, piano key'),
        pointer: 1, kind: PointerDeviceKind.touch);
    final second = await tester.startGesture(keyCenter(tester, 'E 4, piano key'),
        pointer: 2, kind: PointerDeviceKind.touch);
    await tester.pump();
    expect(engine.played, hasLength(2));
    expect(engine.released, isEmpty);
    await first.up();
    await second.up();
  });

  testWidgets('octave down clamps: A0 becomes reachable and button disables',
      (tester) async {
    await pumpScreen(tester);
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.bySemanticsLabel('Octave down'));
      await tester.pump();
    }
    expect(find.text('A0'), findsOneWidget);
    final buttons =
        tester.widgetList<IconButton>(find.byType(IconButton)).toList();
    expect(buttons.first.onPressed, isNull);
  });

  testWidgets('octave shift announces the new range for screen readers',
      (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.bySemanticsLabel('Octave down'));
    await tester.pump();
    expect(tester.takeAnnouncements().single.message, 'Keys C3 to F4');
  });

  testWidgets('bigger keys shows 7 white keys, smaller shows 15', (tester) async {
    await pumpScreen(tester);
    await tester.ensureVisible(find.text('Bigger keys'));
    await tester.tap(find.text('Bigger keys'));
    await tester.pump();
    // Labels on by default: count white-key label texts.
    final labels = find.textContaining(RegExp(r'^[A-G]\d$'));
    expect(labels, findsNWidgets(7));
    await tester.ensureVisible(find.text('Smaller keys'));
    await tester.tap(find.text('Smaller keys'));
    await tester.pump();
    await tester.ensureVisible(find.text('Smaller keys'));
    await tester.tap(find.text('Smaller keys'));
    await tester.pump();
    expect(labels, findsNWidgets(15));
    expect(find.text('C4'), findsOneWidget);
    expect(find.text('C6'), findsOneWidget); // two full octaves, C to C
  });

  testWidgets('size change at the right clamp keeps C8 in view', (tester) async {
    await pumpScreen(tester);
    final up = find.bySemanticsLabel('Octave up');
    for (var i = 0; i < 3; i++) {
      await tester.tap(up);
      await tester.pump();
    }
    expect(find.text('C8'), findsOneWidget); // right-clamped
    await tester.ensureVisible(find.text('Bigger keys'));
    await tester.tap(find.text('Bigger keys'));
    await tester.pump();
    expect(find.text('C8'), findsOneWidget); // still right-anchored
    await tester.ensureVisible(find.text('Smaller keys'));
    await tester.tap(find.text('Smaller keys'));
    await tester.pump();
    expect(find.text('C8'), findsOneWidget);
  });

  testWidgets('TalkBack tap activation plays and releases', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(tester);
    final semantics = tester.getSemantics(find.bySemanticsLabel('C 4, piano key'));
    // Dispatch on the node's own owner: the tested view's semantics owner is
    // not the binding's rootPipelineOwner one.
    semantics.owner!.performAction(semantics.id, SemanticsAction.tap);
    await tester.pump();
    expect(engine.played, hasLength(1));
    expect(haptics.pressed, [60]);
    await tester.pump(const Duration(milliseconds: 700));
    expect(engine.released, hasLength(1));
    handle.dispose();
  });
}
