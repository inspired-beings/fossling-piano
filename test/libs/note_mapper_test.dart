import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:piano/libs/note_mapper.dart';

void main() {
  const mapper = NoteMapper();

  test('sampled notes map to themselves with factor 1.0', () {
    for (final midi in [21, 24, 60, 108]) {
      final s = mapper.map(midi);
      expect(s.assetPath, 'assets/samples/m$midi.ogg');
      expect(s.pitchFactor, 1.0);
    }
  });

  test('one semitone above a sample shifts up by 2^(1/12)', () {
    final s = mapper.map(61); // C#4, nearest sample C4=60
    expect(s.assetPath, 'assets/samples/m60.ogg');
    expect(s.pitchFactor, closeTo(math.pow(2, 1 / 12).toDouble(), 1e-9));
  });

  test('one semitone below a sample shifts down by 2^(-1/12)', () {
    final s = mapper.map(23); // B0, nearest sample C1=24
    expect(s.assetPath, 'assets/samples/m24.ogg');
    expect(s.pitchFactor, closeTo(math.pow(2, -1 / 12).toDouble(), 1e-9));
  });

  test('never shifts more than one semitone across the full range', () {
    for (var midi = NoteMapper.lowestMidi; midi <= NoteMapper.highestMidi; midi++) {
      expect((midi - mapper.nearestSampleMidi(midi)).abs(), lessThanOrEqualTo(1));
    }
  });

  test('exposes 30 sample asset paths', () {
    expect(NoteMapper.sampleAssetPaths, hasLength(30));
    expect(NoteMapper.sampleAssetPaths.first, 'assets/samples/m21.ogg');
    expect(NoteMapper.sampleAssetPaths.last, 'assets/samples/m108.ogg');
  });
}
