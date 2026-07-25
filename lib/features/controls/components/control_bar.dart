import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'control_toggle_button.dart';
import 'octave_button.dart';

class ControlBar extends StatelessWidget {
  const ControlBar({
    super.key,
    required this.canGoOctaveDown,
    required this.canGoOctaveUp,
    required this.onOctaveDown,
    required this.onOctaveUp,
    required this.labelsOn,
    required this.onLabelsToggle,
    required this.sustainOn,
    required this.onSustainToggle,
    required this.largeKeysOn,
    required this.onLargeKeysToggle,
  });

  final bool canGoOctaveDown;
  final bool canGoOctaveUp;
  final VoidCallback onOctaveDown;
  final VoidCallback onOctaveUp;
  final bool labelsOn;
  final VoidCallback onLabelsToggle;
  final bool sustainOn;
  final VoidCallback onSustainToggle;
  final bool largeKeysOn;
  final VoidCallback onLargeKeysToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        spacing: 8,
        children: [
          OctaveButton(
            icon: Icons.chevron_left,
            semanticsLabel: l10n.octavePrevious,
            onPressed: canGoOctaveDown ? onOctaveDown : null,
          ),
          OctaveButton(
            icon: Icons.chevron_right,
            semanticsLabel: l10n.octaveNext,
            onPressed: canGoOctaveUp ? onOctaveUp : null,
          ),
          ControlToggleButton(
            icon: Icons.abc,
            label: l10n.toggleNoteLabels,
            selected: labelsOn,
            onPressed: onLabelsToggle,
          ),
          ControlToggleButton(
            icon: Icons.all_inclusive,
            label: l10n.toggleSustain,
            selected: sustainOn,
            onPressed: onSustainToggle,
          ),
          ControlToggleButton(
            icon: Icons.zoom_in,
            label: l10n.toggleLargeKeys,
            selected: largeKeysOn,
            onPressed: onLargeKeysToggle,
          ),
        ],
      ),
    );
  }
}
