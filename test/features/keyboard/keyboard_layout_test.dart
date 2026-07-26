import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piano/features/keyboard/constants.dart';
import 'package:piano/features/keyboard/keyboard_layout.dart';

void main() {
  test('white midi list spans A0..C8 with 52 keys', () {
    expect(whiteMidis, hasLength(kWhiteKeyTotal));
    expect(whiteMidis.first, 21);
    expect(whiteMidis.last, 108);
    expect(whiteMidis[kDefaultFirstWhiteIndex], 60); // C4
  });

  test('default viewport starts on middle C and shows C4..F5', () {
    final layout = KeyboardLayout(
      firstWhiteIndex: kDefaultFirstWhiteIndex,
      whiteKeyCount: 11,
      size: const Size(1100, 400),
    );
    expect(layout.whiteKeys, hasLength(11));
    expect(layout.whiteKeys.first.midi, 60); // C4
    expect(layout.whiteKeys.last.midi, 77); // F5
    // 7 interior blacks + the clipped F#5 at the right edge; B3|C4 has none.
    expect(layout.blackKeys, hasLength(8));
    expect(layout.blackKeys.map((k) => k.midi), contains(78)); // F#5
  });

  test('viewport starting at A0 includes clipped right-edge black', () {
    final layout = KeyboardLayout(
      firstWhiteIndex: 0,
      whiteKeyCount: 11,
      size: const Size(1100, 400),
    );
    expect(layout.whiteKeys.last.midi, 38); // D2
    expect(layout.blackKeys.map((k) => k.midi), contains(39)); // D#2 at the edge
  });

  test('white keys tile the width evenly', () {
    final layout = KeyboardLayout(
      firstWhiteIndex: 19,
      whiteKeyCount: 11,
      size: const Size(1100, 400),
    );
    expect(layout.whiteKeys[0].rect, const Rect.fromLTWH(0, 0, 100, 400));
    expect(layout.whiteKeys[1].rect, const Rect.fromLTWH(100, 0, 100, 400));
  });

  test('hitTest prefers black keys and returns null outside', () {
    final layout = KeyboardLayout(
      firstWhiteIndex: kDefaultFirstWhiteIndex,
      whiteKeyCount: 11,
      size: const Size(1100, 400),
    );
    expect(layout.hitTest(const Offset(100, 50)), 61); // C#4 straddles C4|D4
    expect(layout.hitTest(const Offset(100, 390)), anyOf(60, 62)); // below blacks
    expect(layout.hitTest(const Offset(-1, 50)), isNull);
    expect(layout.hitTest(const Offset(50, 401)), isNull);
  });

  test('black keys never drop below the 48dp target floor', () {
    final layout = KeyboardLayout(
      firstWhiteIndex: 19,
      whiteKeyCount: 11,
      size: const Size(800, 400), // whiteWidth 72.7 → 0.6 ratio would give 43.6
    );
    for (final key in layout.blackKeys) {
      expect(key.rect.width, greaterThanOrEqualTo(48.0));
    }
  });

  test('octave shifts snap back to the C-anchored home grid after a clamp', () {
    // Down from the default C4 view: C3, C2, C1, then clamped to A0.
    expect(shiftedFirstWhiteIndex(23, -1, 11), 16);
    expect(shiftedFirstWhiteIndex(16, -1, 11), 9);
    expect(shiftedFirstWhiteIndex(9, -1, 11), 2);
    expect(shiftedFirstWhiteIndex(2, -1, 11), 0);
    // Back up: rejoins the C grid instead of staying A-anchored.
    expect(shiftedFirstWhiteIndex(0, 1, 11), 2);
    expect(shiftedFirstWhiteIndex(2, 1, 11), 9);
    // Top end: C7 (37) → clamp 41, and back down rejoins the C grid.
    expect(shiftedFirstWhiteIndex(37, 1, 11), 41);
    expect(shiftedFirstWhiteIndex(41, -1, 11), 37);
  });

  test('clampFirstWhiteIndex keeps viewport inside A0..C8', () {
    expect(clampFirstWhiteIndex(-3, 11), 0);
    expect(clampFirstWhiteIndex(45, 11), 41);
    expect(clampFirstWhiteIndex(50, 7), 45);
    expect(clampFirstWhiteIndex(19, 11), 19);
  });
}
