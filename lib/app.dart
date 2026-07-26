import 'package:flutter/material.dart';

import 'features/keyboard/key_haptics.dart';
import 'l10n/generated/app_localizations.dart';
import 'libs/audio/audio_engine.dart';
import 'libs/audio/soloud_audio_engine.dart';
import 'libs/build_app_theme.dart';
import 'libs/note_mapper.dart';
import 'libs/settings/piano_settings.dart';
import 'libs/settings/settings_store.dart';
import 'libs/settings/shared_prefs_settings_store.dart';
import 'screens/audio_failure_screen.dart';
import 'screens/boot_screen.dart';
import 'screens/piano_screen.dart';

class PianoApp extends StatefulWidget {
  const PianoApp({super.key, this.engine, this.haptics, this.settingsStore});

  final AudioEngine? engine;
  final KeyHaptics? haptics;
  final SettingsStore? settingsStore;

  @override
  State<PianoApp> createState() => _PianoAppState();
}

class _PianoAppState extends State<PianoApp> {
  late final AudioEngine _engine = widget.engine ?? SoLoudAudioEngine();
  late final KeyHaptics _haptics = widget.haptics ?? const KeyHaptics();
  late final SettingsStore _settingsStore =
      widget.settingsStore ?? SharedPrefsSettingsStore();
  late Future<PianoSettings> _boot = _bootstrap();

  Future<PianoSettings> _bootstrap() async {
    await _engine.init();
    await _engine.loadSamples(NoteMapper.sampleAssetPaths);
    return _settingsStore.load();
  }

  void _retry() => setState(() => _boot = _bootstrap());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FutureBuilder<PianoSettings>(
        future: _boot,
        builder: (context, snapshot) {
          if (snapshot.hasError) return AudioFailureScreen(onRetry: _retry);
          if (snapshot.connectionState != ConnectionState.done) {
            return const BootScreen();
          }
          return PianoScreen(
            engine: _engine,
            haptics: _haptics,
            settingsStore: _settingsStore,
            initialSettings: snapshot.requireData,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}
