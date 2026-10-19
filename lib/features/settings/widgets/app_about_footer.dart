import 'package:flutter/material.dart';
import 'package:mya/core/constants/app_legal.dart';

/// Copyright et éditeur (Zonakron édition).
class AppAboutFooter extends StatelessWidget {
  const AppAboutFooter({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white54,
      height: 1.35,
    );

    if (compact) {
      return Text(AppLegal.copyrightLine, style: style, textAlign: TextAlign.center);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Éditeur : ${AppLegal.publisherName}',
          style: style,
        ),
        const SizedBox(height: 4),
        Text(AppLegal.copyrightLine, style: style),
        const SizedBox(height: 8),
        Text(AppLegal.aboutBlurb, style: style),
      ],
    );
  }
}
