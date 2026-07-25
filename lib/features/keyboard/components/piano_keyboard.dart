import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../libs/note_names.dart';
import '../keyboard_layout.dart';
import 'piano_key.dart';

class PianoKeyboard extends StatelessWidget {
  const PianoKeyboard({
    super.key,
    required this.firstWhiteIndex,
    required this.whiteKeyCount,
    required this.showLabels,
    required this.pressedMidis,
    required this.onKeyDown,
    required this.onKeyMove,
    required this.onKeyUp,
    required this.onKeyTap,
  });

  final int firstWhiteIndex;
  final int whiteKeyCount;
  final bool showLabels;
  final Set<int> pressedMidis;
  final void Function(int pointerId, int? midi) onKeyDown;
  final void Function(int pointerId, int? midi) onKeyMove;
  final void Function(int pointerId) onKeyUp;
  final void Function(int midi) onKeyTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final layout = KeyboardLayout(
        firstWhiteIndex: firstWhiteIndex,
        whiteKeyCount: whiteKeyCount,
        size: constraints.biggest,
      );
      Widget keyFor(KeyGeometry key) => Positioned.fromRect(
            rect: key.rect,
            child: PianoKey(
              isBlack: key.isBlack,
              pressed: pressedMidis.contains(key.midi),
              semanticsLabel: l10n.keySemantics(
                  spokenNoteName(l10n, key.midi), octaveNumber(key.midi)),
              onTap: () => onKeyTap(key.midi),
              label: showLabels && !key.isBlack ? visualNoteLabel(l10n, key.midi) : null,
            ),
          );
      return Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (event) => onKeyDown(event.pointer, layout.hitTest(event.localPosition)),
        onPointerMove: (event) => onKeyMove(event.pointer, layout.hitTest(event.localPosition)),
        onPointerUp: (event) => onKeyUp(event.pointer),
        onPointerCancel: (event) => onKeyUp(event.pointer),
        child: ClipRect(
          child: Stack(children: [
            for (final key in layout.whiteKeys) keyFor(key),
            for (final key in layout.blackKeys) keyFor(key),
          ]),
        ),
      );
    });
  }
}
