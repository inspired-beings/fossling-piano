import 'package:flutter/material.dart';

class PianoKey extends StatelessWidget {
  const PianoKey({
    super.key,
    required this.isBlack,
    required this.pressed,
    required this.semanticsLabel,
    required this.onTap,
    this.label,
  });

  final bool isBlack;
  final bool pressed;
  final String semanticsLabel;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fill = pressed
        ? scheme.primaryContainer
        : (isBlack ? scheme.inverseSurface : scheme.surface);
    final labelColor = pressed ? scheme.onPrimaryContainer : scheme.onSurface;
    return Semantics(
      label: semanticsLabel,
      button: true,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: scheme.onSurface, width: 2),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
        ),
        child: label == null
            ? const SizedBox.expand()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ExcludeSemantics(
                    child: Text(
                      label!,
                      style: theme.textTheme.labelLarge?.copyWith(color: labelColor),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
