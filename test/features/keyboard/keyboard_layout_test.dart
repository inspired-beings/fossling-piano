import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piano/features/keyboard/constants.dart';
import 'package:piano/features/keyboard/keyboard_layout.dart';

void main() {
  test('white midi list spans A0..C8 with 52 keys', () {
    expect(whiteMidis, hasLength(kWhiteKeyTotal));
    expect(whiteMidis.first, 21);
    expect(whiteMidis.last, 108);
    expect(whiteMidis[kDefaultFirstWhiteIndex], 53); // F3
  });

  test('normal viewport from F3 shows F3..B4, no black at either edge', () {
    final layout = KeyboardLayout(
      firstWhiteIndex: kDefaultFirstWhiteIndex,
      whiteKeyCount: kNormalWhiteKeyCount,
      size: const Size(1100, 400),
    );
    expect(layout.whiteKeys, hasLength(11));
    expect(layout.whiteKeys.first.midi, 53); // F3
    expect(layout.whiteKeys.last.midi, 71); // B4
    // Interior blacks: F#3 G#3 A#3 C#4 D#4 F#4 G#4 A#4; E3|F3 and B4|C5 gaps have none.
    expect(layout.blackKeys, hasLength(8));
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
      firstWhiteIndex: 19,
      whiteKeyCount: 11,
      size: const Size(1100, 400),
    );
    expect(layout.hitTest(const Offset(100, 50)), 54); // F#3 straddles F3|G3
    expect(layout.hitTest(const Offset(100, 390)), anyOf(53, 55)); // below blacks
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

  test('clampFirstWhiteIndex keeps viewport inside A0..C8', () {
    expect(clampFirstWhiteIndex(-3, 11), 0);
    expect(clampFirstWhiteIndex(45, 11), 41);
    expect(clampFirstWhiteIndex(50, 7), 45);
    expect(clampFirstWhiteIndex(19, 11), 19);
  });
}
