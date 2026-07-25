import 'package:flutter_soloud/flutter_soloud.dart';

import 'audio_engine.dart';

class SoLoudAudioEngine implements AudioEngine {
  final SoLoud _soloud = SoLoud.instance;
  final Map<String, AudioSource> _sources = {};

  static const Duration _releaseFade = Duration(milliseconds: 180);
  // 10 fingers of glissando with sustained tails needs headroom.
  static const int _maxVoices = 64;

  @override
  Future<void> init() async {
    await _soloud.init();
    _soloud.setMaxActiveVoiceCount(_maxVoices);
  }

  @override
  Future<void> loadSamples(List<String> assetPaths) async {
    for (final path in assetPaths) {
      _sources[path] = await _soloud.loadAsset(path);
    }
  }

  @override
  Future<AudioVoice> play(String assetPath, double pitchFactor) async {
    final source = _sources[assetPath];
    if (source == null) throw StateError('sample not loaded: $assetPath');
    final handle = _soloud.play(source);
    _soloud.setRelativePlaySpeed(handle, pitchFactor);
    return AudioVoice(handle);
  }

  @override
  Future<void> release(AudioVoice voice, {required bool sustain}) async {
    if (sustain) return; // ring out naturally to sample end
    final handle = voice.handle as SoundHandle;
    _soloud.fadeVolume(handle, 0, _releaseFade);
    _soloud.scheduleStop(handle, _releaseFade + const Duration(milliseconds: 20));
  }

  @override
  Future<void> dispose() async {
    _soloud.deinit();
  }
}
