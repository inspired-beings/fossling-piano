import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piano/l10n/generated/app_localizations.dart';
import 'package:piano/libs/note_names.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final fr = lookupAppLocalizations(const Locale('fr'));

  test('octave numbers follow scientific pitch notation', () {
    expect(octaveNumber(60), 4); // C4
    expect(octaveNumber(21), 0); // A0
    expect(octaveNumber(108), 8); // C8
  });

  test('spoken names are locale-aware', () {
    expect(spokenNoteName(en, 61), 'C sharp');
    expect(spokenNoteName(fr, 61), 'do dièse');
  });

  test('visual labels combine name and octave', () {
    expect(visualNoteLabel(en, 60), 'C4');
    expect(visualNoteLabel(fr, 60), 'do4');
  });
}
