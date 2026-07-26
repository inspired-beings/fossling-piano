import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../features/controls/components/control_bar.dart';
import '../l10n/generated/app_localizations.dart';
import '../libs/note_names.dart';
import '../features/keyboard/components/piano_keyboard.dart';
import '../features/keyboard/constants.dart';
import '../features/keyboard/key_haptics.dart';
import '../features/keyboard/keyboard_layout.dart';
import '../features/keyboard/pointer_tracker.dart';
import '../features/keyboard/types.dart';
import '../libs/audio/audio_engine.dart';
import '../libs/note_mapper.dart';
import '../libs/settings/piano_settings.dart';
import '../libs/settings/settings_store.dart';

class PianoScreen extends StatefulWidget {
  const PianoScreen({
    super.key,
    required this.engine,
    required this.haptics,
    required this.settingsStore,
    this.initialSettings = const PianoSettings(),
  });

  final AudioEngine engine;
  final KeyHaptics haptics;
  final SettingsStore settingsStore;
  final PianoSettings initialSettings;

  @override
  State<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends State<PianoScreen> {
  static const _mapper = NoteMapper();
  static const _talkBackNoteLength = Duration(milliseconds: 600);

  final PointerTracker _tracker = PointerTracker();
  final Map<int, AudioVoice> _pointerVoices = {};

  late int _firstWhiteIndex = widget.initialSettings.sanitized().firstWhiteIndex;
  late bool _labelsOn = widget.initialSettings.labelsOn;
  late bool _sustainOn = widget.initialSettings.sustainOn;
  late int _sizeStep = widget.initialSettings.sanitized().sizeStep;

  void _persist() {
    // Fire-and-forget: persistence must never block or fail playing.
    widget.settingsStore.save(PianoSettings(
      firstWhiteIndex: _firstWhiteIndex,
      labelsOn: _labelsOn,
      sustainOn: _sustainOn,
      sizeStep: _sizeStep,
    ));
  }

  /// Caps the viewport so every white key keeps a ≥48dp target on any width.
  int _whiteKeyCountFor(double width) {
    final maxKeys = math.max(3, width ~/ 48);
    return math.min(kWhiteKeyCountSteps[_sizeStep], maxKeys);
  }

  void _changeKeySize(int delta, double width) {
    setState(() {
      final oldCount = _whiteKeyCountFor(width);
      final wasRightClamped = _firstWhiteIndex >= kWhiteKeyTotal - oldCount;
      _sizeStep = (_sizeStep + delta).clamp(0, kWhiteKeyCountSteps.length - 1);
      final newCount = _whiteKeyCountFor(width);
      // Keep the right end in view when zooming at the right clamp; everywhere
      // else the leftmost key stays the anchor.
      _firstWhiteIndex = wasRightClamped
          ? kWhiteKeyTotal - newCount
          : clampFirstWhiteIndex(_firstWhiteIndex, newCount);
    });
    _persist();
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

  void _shiftOctave(int direction, int whiteKeyCount) {
    setState(() {
      _firstWhiteIndex =
          shiftedFirstWhiteIndex(_firstWhiteIndex, direction, whiteKeyCount);
    });
    _persist();
    // Octave moves are silent, so TalkBack users need the new range spoken.
    final l10n = AppLocalizations.of(context);
    SemanticsService.sendAnnouncement(
      View.of(context),
      l10n.octaveRangeAnnouncement(
        visualNoteLabel(l10n, whiteMidis[_firstWhiteIndex]),
        visualNoteLabel(l10n, whiteMidis[_firstWhiteIndex + whiteKeyCount - 1]),
      ),
      Directionality.of(context),
    );
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
                onOctaveDown: () => _shiftOctave(-1, whiteKeyCount),
                onOctaveUp: () => _shiftOctave(1, whiteKeyCount),
                labelsOn: _labelsOn,
                onLabelsToggle: () {
                  setState(() => _labelsOn = !_labelsOn);
                  _persist();
                },
                sustainOn: _sustainOn,
                onSustainToggle: () {
                  setState(() => _sustainOn = !_sustainOn);
                  _persist();
                },
                onBiggerKeys: _sizeStep < kWhiteKeyCountSteps.length - 1
                    ? () => _changeKeySize(1, constraints.maxWidth)
                    : null,
                onSmallerKeys: _sizeStep > 0
                    ? () => _changeKeySize(-1, constraints.maxWidth)
                    : null,
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
