import 'dart:ui';

import '../../libs/note_mapper.dart';
import 'constants.dart';

const Set<int> _whitePitchClasses = {0, 2, 4, 5, 7, 9, 11};

bool isWhiteMidi(int midi) => _whitePitchClasses.contains(midi % 12);

final List<int> whiteMidis = List.unmodifiable([
  for (var midi = NoteMapper.lowestMidi; midi <= NoteMapper.highestMidi; midi++)
    if (isWhiteMidi(midi)) midi,
]);

int clampFirstWhiteIndex(int index, int whiteKeyCount) =>
    index.clamp(0, kWhiteKeyTotal - whiteKeyCount);

class KeyGeometry {
  const KeyGeometry({required this.midi, required this.rect, required this.isBlack});

  final int midi;
  final Rect rect;
  final bool isBlack;
}

/// Pure keyboard geometry for one viewport: white-key row + black overlay,
/// including blacks clipped at the viewport edges so every note stays playable.
class KeyboardLayout {
  KeyboardLayout({
    required this.firstWhiteIndex,
    required this.whiteKeyCount,
    required this.size,
  }) {
    final whiteWidth = size.width / whiteKeyCount;
    whiteKeys = List.unmodifiable([
      for (var i = 0; i < whiteKeyCount; i++)
        KeyGeometry(
          midi: whiteMidis[firstWhiteIndex + i],
          rect: Rect.fromLTWH(i * whiteWidth, 0, whiteWidth, size.height),
          isBlack: false,
        ),
    ]);
    final blackWidth = whiteWidth * 0.6;
    final blackHeight = size.height * 0.62;
    blackKeys = List.unmodifiable([
      for (var i = -1; i < whiteKeyCount; i++)
        if (firstWhiteIndex + i >= 0 &&
            firstWhiteIndex + i + 1 < kWhiteKeyTotal &&
            whiteMidis[firstWhiteIndex + i + 1] - whiteMidis[firstWhiteIndex + i] == 2)
          KeyGeometry(
            midi: whiteMidis[firstWhiteIndex + i] + 1,
            rect: Rect.fromLTWH(
                (i + 1) * whiteWidth - blackWidth / 2, 0, blackWidth, blackHeight),
            isBlack: true,
          ),
    ]);
  }

  final int firstWhiteIndex;
  final int whiteKeyCount;
  final Size size;
  late final List<KeyGeometry> whiteKeys;
  late final List<KeyGeometry> blackKeys;

  int? hitTest(Offset position) {
    if (!(Offset.zero & size).contains(position)) return null;
    for (final key in blackKeys) {
      if (key.rect.contains(position)) return key.midi;
    }
    for (final key in whiteKeys) {
      if (key.rect.contains(position)) return key.midi;
    }
    return null;
  }
}
