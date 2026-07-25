import 'package:piano/libs/audio/audio_engine.dart';

class PlayedNote {
  PlayedNote(this.assetPath, this.pitchFactor);

  final String assetPath;
  final double pitchFactor;
}

class ReleasedNote {
  ReleasedNote(this.voice, this.sustain);

  final AudioVoice voice;
  final bool sustain;
}

class FakeAudioEngine implements AudioEngine {
  FakeAudioEngine({this.failInit = false, this.failLoad = false});

  final bool failInit;
  final bool failLoad;
  final List<PlayedNote> played = [];
  final List<ReleasedNote> released = [];
  final List<String> loaded = [];
  bool initialized = false;
  bool disposed = false;
  int _nextHandle = 0;

  @override
  Future<void> init() async {
    if (failInit) throw StateError('fake init failure');
    initialized = true;
  }

  @override
  Future<void> loadSamples(List<String> assetPaths) async {
    if (failLoad) throw StateError('fake load failure');
    loaded.addAll(assetPaths);
  }

  @override
  Future<AudioVoice> play(String assetPath, double pitchFactor) async {
    played.add(PlayedNote(assetPath, pitchFactor));
    return AudioVoice(_nextHandle++);
  }

  @override
  Future<void> release(AudioVoice voice, {required bool sustain}) async {
    released.add(ReleasedNote(voice, sustain));
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}
