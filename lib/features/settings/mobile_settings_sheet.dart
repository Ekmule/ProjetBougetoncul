import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_display.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/application/sync/sync_status_provider.dart';
import 'package:mya/application/updates/update_providers.dart';
import 'package:mya/features/settings/widgets/auth_settings_dialog.dart';
import 'package:mya/features/shared/widgets/cloud_sync_badge.dart';
import 'package:mya/platform/android/android_home_widget_bridge.dart';

/// Paramètres compacts pour Android (compte, sync, version).
class MobileSettingsSheet extends ConsumerWidget {
  const MobileSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: MobileSettingsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authConfigured = ref.watch(authConfiguredProvider);
    final syncSnapshot = ref.watch(cloudSyncStatusProvider);
    final packageInfo = ref.watch(packageInfoProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Paramètres', style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: const Text('Compte et synchronisation'),
          subtitle: Text(
            syncSnapshot.accountAndSyncSummary(isConfigured: authConfigured),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            Navigator.of(context).pop();
            await AuthSettingsDialog.show(context);
          },
        ),
        if (Platform.isAndroid) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.widgets_outlined),
            title: const Text('Widget écran d\'accueil'),
            subtitle: const Text('Épingler MYA sur le launcher'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              Navigator.of(context).pop();
              final supported = await AndroidHomeWidgetBridge.isPinSupported();
              if (!context.mounted) return;
              if (supported) {
                await AndroidHomeWidgetBridge.requestPin();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Votre launcher ne permet pas l\'ajout automatique. '
                      'Ajoutez le widget manuellement (appui long → Widgets).',
                    ),
                  ),
                );
              }
            },
          ),
        ],
        if (syncSnapshot.showsConnectedBadge) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: CloudSyncStatusChip(snapshot: syncSnapshot),
          ),
        ],
        const SizedBox(height: 12),
        packageInfo.when(
          data: (info) => Text(
            'Version ${info.version}'
            '${info.buildNumber.isEmpty ? '' : ' (build ${info.buildNumber})'}',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        if (!authConfigured) ...[
          const SizedBox(height: 12),
          Text(
            'Supabase non configuré dans cette build.',
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            AuthDisplay.accountSummary(
              ref.watch(authUserProvider).value,
              isConfigured: authConfigured,
            ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
