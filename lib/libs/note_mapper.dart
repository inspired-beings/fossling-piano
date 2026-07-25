import 'dart:math' as math;

class SampledNote {
  const SampledNote({required this.assetPath, required this.pitchFactor});

  final String assetPath;
  final double pitchFactor;
}

/// Maps any playable MIDI note (A0=21 … C8=108) to the nearest sampled note
/// and the pitch-shift factor to reach it. Samples sit every 3 semitones,
/// so the shift never exceeds ±1 semitone.
class NoteMapper {
  const NoteMapper();

  static const int lowestMidi = 21;
  static const int highestMidi = 108;
  static const int _sampleStep = 3;

  static List<String> get sampleAssetPaths => [
        for (var midi = lowestMidi; midi <= highestMidi; midi += _sampleStep)
          'assets/samples/m$midi.ogg',
      ];

  int nearestSampleMidi(int midi) {
    assert(midi >= lowestMidi && midi <= highestMidi);
    return lowestMidi + _sampleStep * ((midi - lowestMidi + 1) ~/ _sampleStep);
  }

  SampledNote map(int midi) {
    final sample = nearestSampleMidi(midi);
    return SampledNote(
      assetPath: 'assets/samples/m$sample.ogg',
      pitchFactor: math.pow(2, (midi - sample) / 12).toDouble(),
    );
  }
}
