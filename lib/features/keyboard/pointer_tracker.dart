import 'types.dart';

/// Maps live pointers to sounding notes; a pointer sliding across keys
/// retargets its note (glissando).
class PointerTracker {
  final Map<int, int?> _pointerNotes = {};

  Set<int> get activeMidis =>
      {for (final midi in _pointerNotes.values) ?midi};

  NoteTransition down(int pointerId, int? midi) {
    _pointerNotes[pointerId] = midi;
    return NoteTransition(startedMidi: midi);
  }

  NoteTransition move(int pointerId, int? midi) {
    if (!_pointerNotes.containsKey(pointerId)) return const NoteTransition();
    final previous = _pointerNotes[pointerId];
    if (previous == midi) return const NoteTransition();
    _pointerNotes[pointerId] = midi;
    return NoteTransition(releasedMidi: previous, startedMidi: midi);
  }

  NoteTransition up(int pointerId) {
    final previous = _pointerNotes.remove(pointerId);
    return NoteTransition(releasedMidi: previous);
  }
}
