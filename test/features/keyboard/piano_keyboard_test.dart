import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piano/features/keyboard/components/piano_keyboard.dart';
import 'package:piano/features/keyboard/constants.dart';

import '../../helpers/pump_localized.dart';

void main() {
  Widget keyboard({bool showLabels = true, void Function(int, int?)? onDown}) =>
      PianoKeyboard(
        firstWhiteIndex: kDefaultFirstWhiteIndex,
        whiteKeyCount: kNormalWhiteKeyCount,
        showLabels: showLabels,
        pressedMidis: const {},
        onKeyDown: onDown ?? (_, _) {},
        onKeyMove: (_, _) {},
        onKeyUp: (_) {},
        onKeyTap: (_) {},
      );

  testWidgets('shows localized labels on white keys when enabled', (tester) async {
    await pumpLocalized(tester, keyboard(), locale: const Locale('fr'));
    expect(find.text('do4'), findsOneWidget);
    expect(find.text('C4'), findsNothing);
  });

  testWidgets('hides labels when disabled', (tester) async {
    await pumpLocalized(tester, keyboard(showLabels: false));
    expect(find.text('C4'), findsNothing);
  });

  testWidgets('every key exposes semantics with spoken note name', (tester) async {
    await pumpLocalized(tester, keyboard());
    expect(find.bySemanticsLabel('C 4, piano key'), findsOneWidget);
    expect(find.bySemanticsLabel('F sharp 3, piano key'), findsOneWidget);
  });

  testWidgets('pointer down reaches onKeyDown with the hit midi', (tester) async {
    int? downMidi;
    await pumpLocalized(tester, keyboard(onDown: (_, midi) => downMidi = midi));
    final gesture = await tester.startGesture(
      tester.getCenter(find.bySemanticsLabel('C 4, piano key')),
    );
    expect(downMidi, 60);
    await gesture.up();
  });
}
