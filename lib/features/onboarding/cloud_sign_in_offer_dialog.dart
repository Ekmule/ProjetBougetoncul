import 'package:flutter/material.dart';
import 'package:mya/features/settings/widgets/auth_settings_dialog.dart';
import 'package:mya/l10n/phase_a_strings.dart';

/// Offre de connexion après installation avec sync cloud cochée.
class CloudSignInOfferDialog extends StatelessWidget {
  const CloudSignInOfferDialog({super.key});

  /// Retourne `true` si l'utilisateur veut ouvrir la connexion.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CloudSignInOfferDialog(),
    );
    return result == true;
  }

  static Future<void> openAuthSettings(BuildContext context) {
    return AuthSettingsDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.phaseA;

    return AlertDialog(
      title: Text(strings.cloudSignInOfferTitle),
      content: Text(strings.cloudSignInOfferBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.cloudSignInOfferLater),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(strings.cloudSignInOfferConnect),
        ),
      ],
    );
  }
}
