import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/l10n/first_use_tutorial_strings.dart';

class FirstUseTutorialDialog extends StatelessWidget {
  const FirstUseTutorialDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const FirstUseTutorialDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.firstUseTutorialStrings;

    return AlertDialog(
      title: Text(strings.title),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TutorialStep(
                icon: Icons.edit_outlined,
                text: strings.createTask,
              ),
              _TutorialStep(
                icon: Icons.calendar_month_outlined,
                text: strings.addDate,
              ),
              _TutorialStep(
                icon: Icons.notifications_active_outlined,
                text: strings.enableSuperAlert,
              ),
              _TutorialStep(
                icon: Icons.animation_outlined,
                text: strings.alertBehavior,
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.understood),
        ),
      ],
    );
  }
}

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

Future<void> maybeShowFirstUseTutorial(
  BuildContext context,
  WidgetRef ref,
) async {
  final store = ref.read(deviceSettingsStoreProvider);
  if (store.isFirstUseTutorialCompleted()) return;

  await FirstUseTutorialDialog.show(context);
  await store.markFirstUseTutorialCompleted();
}
