import 'package:flutter/material.dart';
import 'package:mya/l10n/mya_localizations.dart';

/// Copyright et éditeur (Zonakron édition).
class AppAboutFooter extends StatelessWidget {
  const AppAboutFooter({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white54,
      height: 1.35,
    );

    if (compact) {
      return Text(l10n.copyrightLine, style: style, textAlign: TextAlign.center);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.aboutPublisher, style: style),
        const SizedBox(height: 4),
        Text(l10n.copyrightLine, style: style),
        const SizedBox(height: 8),
        Text(l10n.aboutBlurb, style: style),
      ],
    );
  }
}
