class AudioVoice {
  const AudioVoice(this.handle);

  // dynamic: SoundHandle is an extension type that doesn't implement Object.
  final dynamic handle;
}

/// Playback abstraction: the app never talks to the audio plugin directly,
/// so the backend stays swappable (Oboe FFI fallback if QA shows bad latency).
abstract interface class AudioEngine {
  Future<void> init();

  Future<void> loadSamples(List<String> assetPaths);

  Future<AudioVoice> play(String assetPath, double pitchFactor);

  Future<void> release(AudioVoice voice, {required bool sustain});

  Future<void> dispose();
}
