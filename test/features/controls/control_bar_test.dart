import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piano/features/controls/components/control_bar.dart';

import '../../helpers/pump_localized.dart';

void main() {
  Widget bar({
    bool canGoOctaveDown = true,
    bool canGoOctaveUp = true,
    VoidCallback? onLabelsToggle,
    VoidCallback? onSustainToggle,
    VoidCallback? onLargeKeysToggle,
    bool sustainOn = false,
  }) =>
      ControlBar(
        canGoOctaveDown: canGoOctaveDown,
        canGoOctaveUp: canGoOctaveUp,
        onOctaveDown: () {},
        onOctaveUp: () {},
        labelsOn: true,
        onLabelsToggle: onLabelsToggle ?? () {},
        sustainOn: sustainOn,
        onSustainToggle: onSustainToggle ?? () {},
        largeKeysOn: false,
        onLargeKeysToggle: onLargeKeysToggle ?? () {},
      );

  testWidgets('all controls carry localized semantics labels (fr)', (tester) async {
    await pumpLocalized(tester, bar(), locale: const Locale('fr'));
    expect(find.bySemanticsLabel('Octave inférieure'), findsOneWidget);
    expect(find.bySemanticsLabel('Octave supérieure'), findsOneWidget);
    expect(find.text('Noms des notes'), findsOneWidget);
    expect(find.text('Résonance'), findsOneWidget);
    expect(find.text('Grandes touches'), findsOneWidget);
  });

  testWidgets('octave buttons disable at the range ends', (tester) async {
    await pumpLocalized(tester, bar(canGoOctaveDown: false, canGoOctaveUp: false));
    final buttons = tester
        .widgetList<IconButton>(find.byType(IconButton))
        .toList();
    expect(buttons, hasLength(2));
    for (final b in buttons) {
      expect(b.onPressed, isNull);
    }
  });

  testWidgets('toggles fire their callbacks', (tester) async {
    var labels = 0, sustain = 0, large = 0;
    await pumpLocalized(
      tester,
      bar(
        onLabelsToggle: () => labels++,
        onSustainToggle: () => sustain++,
        onLargeKeysToggle: () => large++,
      ),
    );
    await tester.tap(find.text('Note names'));
    await tester.tap(find.text('Sustain'));
    await tester.tap(find.text('Large keys'));
    expect((labels, sustain, large), (1, 1, 1));
  });
}
