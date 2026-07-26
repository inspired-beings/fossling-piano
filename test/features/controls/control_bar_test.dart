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
    VoidCallback? onBiggerKeys,
    VoidCallback? onSmallerKeys,
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
        onBiggerKeys: onBiggerKeys ?? () {},
        onSmallerKeys: onSmallerKeys ?? () {},
      );

  testWidgets('all controls carry localized semantics labels (fr)', (tester) async {
    await pumpLocalized(tester, bar(), locale: const Locale('fr'));
    expect(find.bySemanticsLabel('Octave inférieure'), findsOneWidget);
    expect(find.bySemanticsLabel('Octave supérieure'), findsOneWidget);
    expect(find.text('Noms des notes'), findsOneWidget);
    expect(find.text('Résonance'), findsOneWidget);
    expect(find.text('Touches plus grandes'), findsOneWidget);
    expect(find.text('Touches plus petites'), findsOneWidget);
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

  testWidgets('toggles and size buttons fire their callbacks', (tester) async {
    var labels = 0, sustain = 0, bigger = 0, smaller = 0;
    await pumpLocalized(
      tester,
      bar(
        onLabelsToggle: () => labels++,
        onSustainToggle: () => sustain++,
        onBiggerKeys: () => bigger++,
        onSmallerKeys: () => smaller++,
      ),
    );
    await tester.tap(find.text('Note names'));
    await tester.tap(find.text('Sustain'));
    await tester.ensureVisible(find.text('Bigger keys'));
    await tester.tap(find.text('Bigger keys'));
    await tester.ensureVisible(find.text('Smaller keys'));
    await tester.tap(find.text('Smaller keys'));
    expect((labels, sustain, bigger, smaller), (1, 1, 1, 1));
  });
}
