import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../features/controls/components/control_bar.dart';
import '../features/keyboard/components/piano_keyboard.dart';
import '../features/keyboard/constants.dart';
import '../features/keyboard/key_haptics.dart';
import '../features/keyboard/keyboard_layout.dart';
import '../features/keyboard/pointer_tracker.dart';
import '../features/keyboard/types.dart';
import '../libs/audio/audio_engine.dart';
import '../libs/note_mapper.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({super.key, required this.engine, required this.haptics});

  final AudioEngine engine;
  final KeyHaptics haptics;

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  static const _mapper = NoteMapper();
  static const _talkBackNoteLength = Duration(milliseconds: 600);

  final PointerTracker _tracker = PointerTracker();
  final Map<int, AudioVoice> _pointerVoices = {};

  int _firstWhiteIndex = kDefaultFirstWhiteIndex;
  bool _labelsOn = true;
  bool _sustainOn = false;
  bool _largeKeysOn = false;

  /// Caps the viewport so every white key keeps a ≥48dp target on any width.
  int _whiteKeyCountFor(double width) {
    final maxKeys = math.max(3, width ~/ 48);
    final wanted = _largeKeysOn ? kLargeWhiteKeyCount : kNormalWhiteKeyCount;
    return math.min(wanted, maxKeys);
  }

  Future<void> _startNote(int pointerId, int midi) async {
    widget.haptics.onKeyPress(midi);
    final sampled = _mapper.map(midi);
    _pointerVoices[pointerId] =
        await widget.engine.play(sampled.assetPath, sampled.pitchFactor);
  }

  void _releaseVoice(int pointerId) {
    final voice = _pointerVoices.remove(pointerId);
    if (voice != null) widget.engine.release(voice, sustain: _sustainOn);
  }

  void _applyTransition(int pointerId, NoteTransition transition) {
    if (transition.releasedMidi != null) _releaseVoice(pointerId);
    if (transition.startedMidi != null) _startNote(pointerId, transition.startedMidi!);
    setState(() {}); // pressed-key set changed
  }

  void _onKeyDown(int pointerId, int? midi) =>
      _applyTransition(pointerId, _tracker.down(pointerId, midi));

  void _onKeyMove(int pointerId, int? midi) =>
      _applyTransition(pointerId, _tracker.move(pointerId, midi));

  void _onKeyUp(int pointerId) => _applyTransition(pointerId, _tracker.up(pointerId));

  Future<void> _onKeyTap(int midi) async {
    // TalkBack double-tap: play a self-releasing note.
    widget.haptics.onKeyPress(midi);
    final sampled = _mapper.map(midi);
    final voice = await widget.engine.play(sampled.assetPath, sampled.pitchFactor);
    await Future<void>.delayed(_talkBackNoteLength);
    await widget.engine.release(voice, sustain: _sustainOn);
  }

  void _shiftOctave(int deltaWhites, int whiteKeyCount) {
    setState(() {
      _firstWhiteIndex =
          clampFirstWhiteIndex(_firstWhiteIndex + deltaWhites, whiteKeyCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final whiteKeyCount = _whiteKeyCountFor(constraints.maxWidth);
          return Column(
            children: [
              ControlBar(
                canGoOctaveDown: _firstWhiteIndex > 0,
                canGoOctaveUp: _firstWhiteIndex < kWhiteKeyTotal - whiteKeyCount,
                onOctaveDown: () => _shiftOctave(-7, whiteKeyCount),
                onOctaveUp: () => _shiftOctave(7, whiteKeyCount),
                labelsOn: _labelsOn,
                onLabelsToggle: () => setState(() => _labelsOn = !_labelsOn),
                sustainOn: _sustainOn,
                onSustainToggle: () => setState(() => _sustainOn = !_sustainOn),
                largeKeysOn: _largeKeysOn,
                onLargeKeysToggle: () => setState(() {
                  _largeKeysOn = !_largeKeysOn;
                }),
              ),
              Expanded(
                child: PianoKeyboard(
                  firstWhiteIndex:
                      clampFirstWhiteIndex(_firstWhiteIndex, whiteKeyCount),
                  whiteKeyCount: whiteKeyCount,
                  showLabels: _labelsOn,
                  pressedMidis: _tracker.activeMidis,
                  onKeyDown: _onKeyDown,
                  onKeyMove: _onKeyMove,
                  onKeyUp: _onKeyUp,
                  onKeyTap: _onKeyTap,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    for (final pointerId in _pointerVoices.keys.toList()) {
      _releaseVoice(pointerId);
    }
    super.dispose();
  }
}
