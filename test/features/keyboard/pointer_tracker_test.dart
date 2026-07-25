import 'package:flutter_test/flutter_test.dart';
import 'package:piano/features/keyboard/pointer_tracker.dart';

void main() {
  late PointerTracker tracker;

  setUp(() => tracker = PointerTracker());

  test('down starts a note, up releases it', () {
    expect(tracker.down(1, 60).startedMidi, 60);
    expect(tracker.activeMidis, {60});
    expect(tracker.up(1).releasedMidi, 60);
    expect(tracker.activeMidis, isEmpty);
  });

  test('two pointers make a chord', () {
    tracker.down(1, 60);
    tracker.down(2, 64);
    expect(tracker.activeMidis, {60, 64});
  });

  test('move across keys retargets (glissando)', () {
    tracker.down(1, 60);
    final t = tracker.move(1, 62);
    expect(t.releasedMidi, 60);
    expect(t.startedMidi, 62);
  });

  test('move within the same key does nothing', () {
    tracker.down(1, 60);
    final t = tracker.move(1, 60);
    expect(t.releasedMidi, isNull);
    expect(t.startedMidi, isNull);
  });

  test('move off the keyboard releases; back on restarts', () {
    tracker.down(1, 60);
    expect(tracker.move(1, null).releasedMidi, 60);
    expect(tracker.move(1, 65).startedMidi, 65);
  });

  test('down on a dead zone tracks the pointer silently', () {
    expect(tracker.down(1, null).startedMidi, isNull);
    expect(tracker.move(1, 60).startedMidi, 60);
  });

  test('up on unknown pointer is a no-op', () {
    final t = tracker.up(9);
    expect(t.releasedMidi, isNull);
    expect(t.startedMidi, isNull);
  });
}
