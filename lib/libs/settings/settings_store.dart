import 'piano_settings.dart';

/// Persistence abstraction — the plugin stays out of widgets and tests.
abstract interface class SettingsStore {
  Future<PianoSettings> load();

  Future<void> save(PianoSettings settings);
}
