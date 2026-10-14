import 'package:flutter/material.dart';
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
    return AlertDialog(
      title: const Text('Ajouter MYA à l\'écran d\'accueil'),
      content: const Text(
        'MYA fonctionne mieux avec son widget 1×1 : un tap ouvre '
        'directement vos tâches.\n\n'
        'Android va vous proposer de le placer sur l\'écran d\'accueil.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Plus tard'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await AndroidHomeWidgetBridge.requestPin();
          },
          child: const Text('Ajouter le widget'),
        ),
      ],
    );
  }
}
