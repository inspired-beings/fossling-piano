import 'package:piano/libs/settings/piano_settings.dart';
import 'package:piano/libs/settings/settings_store.dart';

class FakeSettingsStore implements SettingsStore {
  FakeSettingsStore([PianoSettings? initial])
      : stored = initial ?? const PianoSettings();

  PianoSettings stored;
  int saveCount = 0;

  @override
  Future<PianoSettings> load() async => stored.sanitized();

  @override
  Future<void> save(PianoSettings settings) async {
    stored = settings;
    saveCount++;
  }
}
