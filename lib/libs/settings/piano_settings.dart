import '../../features/keyboard/constants.dart';
import '../../features/keyboard/keyboard_layout.dart';

class PianoSettings {
  const PianoSettings({
    this.firstWhiteIndex = kDefaultFirstWhiteIndex,
    this.labelsOn = true,
    this.sustainOn = false,
    this.sizeStep = kDefaultSizeStep,
  });

  final int firstWhiteIndex;
  final bool labelsOn;
  final bool sustainOn;
  final int sizeStep;

  /// Clamps possibly-stale persisted values back into valid ranges.
  PianoSettings sanitized() => PianoSettings(
        firstWhiteIndex: clampFirstWhiteIndex(
            firstWhiteIndex, kWhiteKeyCountSteps.last),
        labelsOn: labelsOn,
        sustainOn: sustainOn,
        sizeStep: sizeStep.clamp(0, kWhiteKeyCountSteps.length - 1),
      );
}
