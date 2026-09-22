import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_display.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/application/bubble/always_on_top_service.dart';
import 'package:mya/application/bubble/bubble_appearance_notifier.dart';
import 'package:mya/core/constants/window_constants.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/features/settings/widgets/bubble_icon_gallery.dart';
import 'package:mya/features/settings/widgets/auth_settings_dialog.dart';
import 'package:mya/features/settings/widgets/hotkey_settings_dialog.dart';
import 'package:mya/application/hotkeys/global_hotkey_service.dart';
import 'package:mya/platform/platform_providers.dart';

/// Paramètres MYA accessibles depuis le panneau (engrenage).
class BubbleSettingsDialog extends ConsumerStatefulWidget {
  const BubbleSettingsDialog({
    super.key,
    required this.onHotkeyChanged,
    required this.onAccountChanged,
    required this.onShowTrayHint,
  });

  final Future<void> Function() onHotkeyChanged;
  final Future<void> Function() onAccountChanged;
  final Future<void> Function() onShowTrayHint;

  static Future<bool?> show(
    BuildContext context, {
    required Future<void> Function() onHotkeyChanged,
    required Future<void> Function() onAccountChanged,
    required Future<void> Function() onShowTrayHint,
  }) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (context) => BubbleSettingsDialog(
        onHotkeyChanged: onHotkeyChanged,
        onAccountChanged: onAccountChanged,
        onShowTrayHint: onShowTrayHint,
      ),
    );
  }

  @override
  ConsumerState<BubbleSettingsDialog> createState() =>
      _BubbleSettingsDialogState();
}

class _BubbleSettingsDialogState extends ConsumerState<BubbleSettingsDialog> {
  late bool _startupEnabled;
  late bool _alwaysOnTop;
  late double _bubbleSize;
  late String _selectedIconId;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(deviceSettingsStoreProvider).readBubbleSettings();
    final appearance = ref.read(bubbleAppearanceProvider);
    _startupEnabled = settings.startupEnabled;
    _alwaysOnTop = ref.read(alwaysOnTopServiceProvider).isEnabled;
    _bubbleSize = appearance.size;
    _selectedIconId = appearance.iconId;
  }

  Future<void> _applyStartup(bool enabled) async {
    setState(() => _startupEnabled = enabled);
    await ref.read(deviceSettingsStoreProvider).saveStartupEnabled(enabled);
    await ref.read(startupServiceProvider).setEnabled(enabled);
  }

  Future<void> _applyAlwaysOnTop(bool enabled) async {
    setState(() => _alwaysOnTop = enabled);
    await ref.read(alwaysOnTopServiceProvider).setEnabled(enabled);
  }

  Future<void> _applyBubbleSize(double size) async {
    setState(() => _bubbleSize = size);
    await ref.read(bubbleAppearanceProvider.notifier).setSize(size);
  }

  Future<void> _applyIconId(String iconId) async {
    setState(() => _selectedIconId = iconId);
    await ref.read(bubbleAppearanceProvider.notifier).setIconId(iconId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authUserProvider).value;
    final authConfigured = ref.watch(authConfiguredProvider);
    final hotkeyLabel = ref.watch(globalHotkeyServiceProvider).displayLabel;
    final preferCloudSync =
        ref.watch(deviceSettingsStoreProvider).readPreferCloudSync();
    final maxWidth = MediaQuery.sizeOf(context).width - 48;
    final dialogWidth = maxWidth.clamp(280.0, 420.0);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.settings_outlined),
          SizedBox(width: 8),
          Text('Paramètres'),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (preferCloudSync) ...[
                Card(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Synchronisation cloud demandée à l\'installation. '
                      'La connexion de compte sera proposée dès que la sync '
                      'sera disponible (D14–D15).',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                'Pastille',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              BubbleIconGallery(
                selectedIconId: _selectedIconId,
                previewSize: 48,
                onSelected: (iconId) => unawaited(_applyIconId(iconId)),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Démarrage avec Windows'),
                subtitle: const Text(
                  'Lance MYA automatiquement au démarrage du PC.',
                ),
                value: _startupEnabled,
                onChanged: _applyStartup,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Toujours au-dessus'),
                subtitle: const Text(
                  'Garde MYA visible au-dessus des autres fenêtres.',
                ),
                value: _alwaysOnTop,
                onChanged: _applyAlwaysOnTop,
              ),
              const SizedBox(height: 8),
              Text(
                'Taille de la pastille : ${_bubbleSize.toInt()} px',
                style: theme.textTheme.titleSmall,
              ),
              Slider(
                value: _bubbleSize,
                min: WindowConstants.minBubbleSize,
                max: WindowConstants.maxBubbleSize,
                divisions:
                    ((WindowConstants.maxBubbleSize -
                                WindowConstants.minBubbleSize) /
                            WindowConstants.bubbleSizeStep)
                        .round(),
                label: '${_bubbleSize.toInt()} px',
                onChanged: _applyBubbleSize,
              ),
              const Divider(height: 24),
              _SettingsLinkTile(
                icon: Icons.keyboard_outlined,
                title: 'Raccourci de création rapide',
                subtitle: hotkeyLabel,
                onTap: () async {
                  final saved = await HotkeySettingsDialog.show(context);
                  if (saved == true) {
                    await widget.onHotkeyChanged();
                    if (mounted) setState(() {});
                  }
                },
              ),
              _SettingsLinkTile(
                icon: Icons.person_outline,
                title: 'Compte et synchronisation',
                subtitle: AuthDisplay.accountSummary(
                  authUser,
                  isConfigured: authConfigured,
                ),
                onTap: () async {
                  final changed = await AuthSettingsDialog.show(context);
                  if (changed == true) {
                    await widget.onAccountChanged();
                    if (mounted) setState(() {});
                  }
                },
              ),
              const Divider(height: 24),
              _TrayHelpCard(onShowTrayHint: widget.onShowTrayHint),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TrayHelpCard extends StatelessWidget {
  const _TrayHelpCard({required this.onShowTrayHint});

  final Future<void> Function() onShowTrayHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Icône dans la barre des tâches',
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'MYA reste accessible via une icône près de l\'horloge '
              '(zone de notification). Sur Windows 11, cliquez sur ^ si '
              'l\'icône est masquée.\n\n'
              '• Clic gauche : ouvrir MYA\n'
              '• Clic droit : menu (masquer, démarrage auto, quitter…)',
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => onShowTrayHint(),
              icon: const Icon(Icons.campaign_outlined, size: 18),
              label: const Text('Rappel : où trouver l\'icône MYA'),
            ),
          ],
        ),
      ),
    );
  }
}
