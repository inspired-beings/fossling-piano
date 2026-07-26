import 'package:shared_preferences/shared_preferences.dart';

import 'piano_settings.dart';
import 'settings_store.dart';

class SharedPrefsSettingsStore implements SettingsStore {
  static const _kFirstWhiteIndex = 'firstWhiteIndex';
  static const _kLabelsOn = 'labelsOn';
  static const _kSustainOn = 'sustainOn';
  static const _kSizeStep = 'sizeStep';

  @override
  Future<PianoSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    const defaults = PianoSettings();
    return PianoSettings(
      firstWhiteIndex:
          prefs.getInt(_kFirstWhiteIndex) ?? defaults.firstWhiteIndex,
      labelsOn: prefs.getBool(_kLabelsOn) ?? defaults.labelsOn,
      sustainOn: prefs.getBool(_kSustainOn) ?? defaults.sustainOn,
      sizeStep: prefs.getInt(_kSizeStep) ?? defaults.sizeStep,
    ).sanitized();
  }

  @override
  Future<void> save(PianoSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kFirstWhiteIndex, settings.firstWhiteIndex);
    await prefs.setBool(_kLabelsOn, settings.labelsOn);
    await prefs.setBool(_kSustainOn, settings.sustainOn);
    await prefs.setInt(_kSizeStep, settings.sizeStep);
  }
}
