import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/bubble/bubble_appearance_notifier.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/features/settings/widgets/bubble_icon_gallery.dart';
import 'package:mya/l10n/mya_localizations.dart';

/// Écran de bienvenue — choix de l'icône de pastille au premier lancement.
class BubbleIconPickerDialog extends ConsumerStatefulWidget {
  const BubbleIconPickerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => const BubbleIconPickerDialog(),
    );
  }

  @override
  ConsumerState<BubbleIconPickerDialog> createState() =>
      _BubbleIconPickerDialogState();
}

class _BubbleIconPickerDialogState extends ConsumerState<BubbleIconPickerDialog> {
  late String _selectedIconId;

  @override
  void initState() {
    super.initState();
    _selectedIconId = ref.read(bubbleAppearanceProvider).iconId;
  }

  Future<void> _confirm() async {
    await ref.read(bubbleAppearanceProvider.notifier).setIconId(_selectedIconId);
    await ref.read(deviceSettingsStoreProvider).markOnboardingCompleted();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.bubbleIconPickerTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.bubbleIconPickerBody,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            BubbleIconGallery(
              selectedIconId: _selectedIconId,
              previewSize: 64,
              onSelected: (iconId) => setState(() => _selectedIconId = iconId),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: _confirm,
          child: Text(l10n.continueButton),
        ),
      ],
    );
  }
}
