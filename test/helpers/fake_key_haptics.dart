import 'package:piano/features/keyboard/key_haptics.dart';

class FakeKeyHaptics implements KeyHaptics {
  final List<int> pressed = [];

  @override
  void onKeyPress(int midi) => pressed.add(midi);
}
