import '../l10n/generated/app_localizations.dart';

int octaveNumber(int midi) => midi ~/ 12 - 1;

String spokenNoteName(AppLocalizations l10n, int midi) {
  final names = [
    l10n.noteC,
    l10n.noteCSharp,
    l10n.noteD,
    l10n.noteDSharp,
    l10n.noteE,
    l10n.noteF,
    l10n.noteFSharp,
    l10n.noteG,
    l10n.noteGSharp,
    l10n.noteA,
    l10n.noteASharp,
    l10n.noteB,
  ];
  return names[midi % 12];
}

String visualNoteLabel(AppLocalizations l10n, int midi) =>
    '${spokenNoteName(l10n, midi)}${octaveNumber(midi)}';
