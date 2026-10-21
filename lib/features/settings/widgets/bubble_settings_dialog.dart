import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/application/sync/sync_status_provider.dart';
import 'package:mya/application/updates/update_providers.dart';
import 'package:mya/features/settings/widgets/app_about_footer.dart';
import 'package:mya/features/settings/widgets/app_language_settings_section.dart';
import 'package:mya/features/settings/widgets/app_update_dialog.dart';
import 'package:mya/application/bubble/always_on_top_service.dart';
import 'package:mya/application/bubble/bubble_appearance_notifier.dart';
import 'package:mya/application/bubble/bubble_position.dart';
import 'package:mya/core/constants/window_constants.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/features/settings/widgets/bubble_icon_gallery.dart';
import 'package:mya/features/settings/widgets/bubble_position_picker.dart';
import 'package:mya/features/settings/widgets/auth_settings_dialog.dart';
import 'package:mya/features/settings/widgets/hotkey_settings_dialog.dart';
import 'package:mya/application/hotkeys/global_hotkey_service.dart';
import 'package:mya/l10n/mya_localizations.dart';
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
  late bool _freeDragEnabled;
  BubbleAnchor? _selectedAnchor;
  String? _selectedDisplayId;
  List<BubbleDisplay> _displays = const [];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(deviceSettingsStoreProvider).readBubbleSettings();
    final appearance = ref.read(bubbleAppearanceProvider);
    _startupEnabled = settings.startupEnabled;
    _alwaysOnTop = ref.read(alwaysOnTopServiceProvider).isEnabled;
    _bubbleSize = appearance.size;
    _selectedIconId = appearance.iconId;
    _freeDragEnabled = settings.freeDragEnabled;
    _selectedAnchor = settings.anchor;
    _selectedDisplayId = settings.displayId;
    unawaited(_loadDisplays());
  }

  Future<void> _loadDisplays() async {
    final displays = await ref.read(windowServiceProvider).getDisplays();
    if (!mounted) return;
    setState(() {
      _displays = displays;
      final selectedExists = displays.any(
        (display) => display.id == _selectedDisplayId,
      );
      if (!selectedExists) {
        _selectedDisplayId = displays
            .where((display) => display.isPrimary)
            .firstOrNull
            ?.id;
        _selectedDisplayId ??= displays.firstOrNull?.id;
      }
    });
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

  Future<void> _applyAnchor(BubbleAnchor anchor) async {
    setState(() {
      _selectedAnchor = anchor;
      _freeDragEnabled = false;
    });
    final store = ref.read(deviceSettingsStoreProvider);
    await store.saveBubbleFreeDragEnabled(false);
    await store.saveBubbleAnchor(anchor, displayId: _selectedDisplayId);
    final position = await ref
        .read(windowServiceProvider)
        .moveToAnchor(anchor, displayId: _selectedDisplayId);
    await store.saveBubblePosition(position);
  }

  Future<void> _applyDisplay(String? displayId) async {
    if (displayId == null) return;
    setState(() => _selectedDisplayId = displayId);
    await _applyAnchor(_selectedAnchor ?? BubbleAnchor.bottomRight);
  }

  Future<void> _applyFreeDrag(bool enabled) async {
    setState(() => _freeDragEnabled = enabled);
    await ref
        .read(deviceSettingsStoreProvider)
        .saveBubbleFreeDragEnabled(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final authConfigured = ref.watch(authConfiguredProvider);
    final syncSnapshot = ref.watch(cloudSyncStatusProvider);
    final packageInfo = ref.watch(packageInfoProvider);
    final installedVersion = packageInfo.maybeWhen(
      data: (info) =>
          '${info.version}${info.buildNumber.isEmpty ? '' : ' (build ${info.buildNumber})'}',
      orElse: () => '…',
    );
    final hotkeyLabel = ref.watch(globalHotkeyServiceProvider).displayLabel;
    final maxWidth = MediaQuery.sizeOf(context).width - 48;
    final dialogWidth = maxWidth.clamp(280.0, 420.0);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.settings_outlined),
          const SizedBox(width: 8),
          Text(l10n.settingsTitle),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppLanguageSettingsSection(),
              const SizedBox(height: 16),
              Text(l10n.bubbleSectionTitle, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              BubbleIconGallery(
                selectedIconId: _selectedIconId,
                previewSize: 48,
                onSelected: (iconId) => unawaited(_applyIconId(iconId)),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.startupWithWindowsTitle),
                subtitle: Text(l10n.startupWithWindowsSubtitle),
                value: _startupEnabled,
                onChanged: _applyStartup,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.alwaysOnTopTitle),
                subtitle: Text(l10n.alwaysOnTopSubtitle),
                value: _alwaysOnTop,
                onChanged: _applyAlwaysOnTop,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.bubbleSizeLabel(_bubbleSize.toInt()),
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
              const SizedBox(height: 8),
              if (_displays.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                BubblePositionPicker(
                  displays: _displays,
                  selectedDisplayId: _selectedDisplayId,
                  selectedAnchor: _selectedAnchor,
                  freeDragEnabled: _freeDragEnabled,
                  onDisplayChanged: (displayId) =>
                      unawaited(_applyDisplay(displayId)),
                  onAnchorChanged: (anchor) => unawaited(_applyAnchor(anchor)),
                  onFreeDragChanged: (enabled) =>
                      unawaited(_applyFreeDrag(enabled)),
                ),
              const Divider(height: 24),
              _SettingsLinkTile(
                icon: Icons.keyboard_outlined,
                title: l10n.hotkeySettingsTitle,
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
                title: l10n.accountAndSyncTitle,
                subtitle: syncSnapshot.accountAndSyncSummary(
                  l10n: l10n,
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
              _SettingsLinkTile(
                icon: Icons.system_update_alt_outlined,
                title: l10n.updatesTitle,
                subtitle: l10n.updatesSubtitle(installedVersion),
                onTap: () => unawaited(AppUpdateSettingsDialog.show(context)),
              ),
              const Divider(height: 24),
              _TrayHelpCard(l10n: l10n, onShowTrayHint: widget.onShowTrayHint),
              const SizedBox(height: 16),
              const AppAboutFooter(),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.close),
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
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: Colors.white70),
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
  const _TrayHelpCard({required this.l10n, required this.onShowTrayHint});

  final MyaLocalizations l10n;
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
                  l10n.trayHelpTitle,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.trayHelpBody),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => onShowTrayHint(),
              icon: const Icon(Icons.campaign_outlined, size: 18),
              label: Text(l10n.trayHelpButton),
            ),
          ],
        ),
      ),
    );
  }
}
