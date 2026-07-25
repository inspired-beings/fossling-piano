import 'package:flutter/material.dart';

import 'features/keyboard/key_haptics.dart';
import 'l10n/generated/app_localizations.dart';
import 'libs/audio/audio_engine.dart';
import 'libs/audio/soloud_audio_engine.dart';
import 'libs/build_app_theme.dart';
import 'libs/note_mapper.dart';
import 'screens/audio_failure_screen.dart';
import 'screens/boot_screen.dart';
import 'screens/piano_screen.dart';

class PianoApp extends StatefulWidget {
  const PianoApp({super.key, this.engine, this.haptics});

  final AudioEngine? engine;
  final KeyHaptics? haptics;

  @override
  State<PianoApp> createState() => _PianoAppState();
}

class _PianoAppState extends State<PianoApp> {
  late final AudioEngine _engine = widget.engine ?? SoLoudAudioEngine();
  late final KeyHaptics _haptics = widget.haptics ?? const KeyHaptics();
  late Future<void> _boot = _bootstrap();

  Future<void> _bootstrap() async {
    await _engine.init();
    await _engine.loadSamples(NoteMapper.sampleAssetPaths);
  }

  void _retry() => setState(() => _boot = _bootstrap());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: FutureBuilder<void>(
        future: _boot,
        builder: (context, snapshot) {
          if (snapshot.hasError) return AudioFailureScreen(onRetry: _retry);
          if (snapshot.connectionState != ConnectionState.done) {
            return const BootScreen();
          }
          return PianoScreen(engine: _engine, haptics: _haptics);
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
