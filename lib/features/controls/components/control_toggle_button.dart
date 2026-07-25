import 'package:flutter/material.dart';

class ControlToggleButton extends StatelessWidget {
  const ControlToggleButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final button = selected
        ? FilledButton.icon(
            onPressed: onPressed, icon: Icon(icon), label: Text(label))
        : FilledButton.tonalIcon(
            onPressed: onPressed, icon: Icon(icon), label: Text(label));
    return MergeSemantics(
      child: Semantics(toggled: selected, child: button),
    );
  }
}
