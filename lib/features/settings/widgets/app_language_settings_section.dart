import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/localization/app_locale_provider.dart';
import 'package:mya/l10n/app_locale_code.dart';
import 'package:mya/l10n/phase_a_strings.dart';

/// Sélecteur de langue (phase A).
class AppLanguageSettingsSection extends ConsumerWidget {
  const AppLanguageSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final code = AppLocaleCode.parse(locale.languageCode);
    final strings = context.phaseA;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(strings.languageLabel, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SegmentedButton<AppLocaleCode>(
          segments: [
            ButtonSegment(
              value: AppLocaleCode.en,
              label: Text(strings.languageEnglish),
            ),
            ButtonSegment(
              value: AppLocaleCode.fr,
              label: Text(strings.languageFrench),
            ),
          ],
          selected: {code},
          onSelectionChanged: (selection) {
            final next = selection.first;
            unawaited(ref.read(appLocaleProvider.notifier).setLocale(next));
          },
        ),
      ],
    );
  }
}
