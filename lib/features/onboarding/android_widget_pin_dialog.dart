import 'package:flutter/material.dart';
import 'package:mya/l10n/mya_localizations.dart';
import 'package:mya/platform/android/android_home_widget_bridge.dart';

/// Propose d'épingler le widget MYA au premier lancement Android (D17a).
class AndroidWidgetPinDialog extends StatelessWidget {
  const AndroidWidgetPinDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const AndroidWidgetPinDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.homeWidgetPinDialogTitle),
      content: Text(l10n.homeWidgetPinDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.later),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await AndroidHomeWidgetBridge.requestPin();
          },
          child: Text(l10n.homeWidgetPinAdd),
        ),
      ],
    );
  }
}
