import 'package:flutter/material.dart';

class OctaveButton extends StatelessWidget {
  const OctaveButton({
    super.key,
    required this.icon,
    required this.semanticsLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: semanticsLabel,
        child: IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon),
          tooltip: semanticsLabel,
        ),
      ),
    );
  }
}
