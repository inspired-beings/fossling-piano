import 'package:flutter/services.dart';

/// Haptic pulse on every key press; C keys (octave anchors) hit harder.
class KeyHaptics {
  const KeyHaptics();

  void onKeyPress(int midi) {
    if (midi % 12 == 0) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }
}
