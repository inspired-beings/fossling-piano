import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class AudioFailureScreen extends StatelessWidget {
  const AudioFailureScreen({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_off, size: 64, semanticLabel: l10n.audioErrorTitle),
              const SizedBox(height: 16),
              Text(
                l10n.audioErrorTitle,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(l10n.audioErrorBody, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(onPressed: onRetry, child: Text(l10n.audioErrorRetry)),
            ],
          ),
        ),
      ),
    );
  }
}
