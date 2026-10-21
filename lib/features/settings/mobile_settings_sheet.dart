import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_display.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/application/sync/sync_status_provider.dart';
import 'package:mya/application/updates/update_providers.dart';
import 'package:mya/features/settings/widgets/app_about_footer.dart';
import 'package:mya/features/settings/widgets/app_language_settings_section.dart';
import 'package:mya/features/settings/widgets/app_update_dialog.dart';
import 'package:mya/features/settings/widgets/auth_settings_dialog.dart';
import 'package:mya/features/shared/widgets/cloud_sync_badge.dart';
import 'package:mya/l10n/mya_localizations.dart';
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
    final l10n = context.l10n;
    final authConfigured = ref.watch(authConfiguredProvider);
    final syncSnapshot = ref.watch(cloudSyncStatusProvider);
    final packageInfo = ref.watch(packageInfoProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.settingsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.person_outline),
          title: Text(l10n.accountAndSyncTitle),
          subtitle: Text(
            syncSnapshot.accountAndSyncSummary(
              l10n: l10n,
              isConfigured: authConfigured,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            Navigator.of(context).pop();
            await AuthSettingsDialog.show(context);
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.system_update_alt_outlined),
          title: Text(l10n.updatesTitle),
          subtitle: packageInfo.when(
            data: (info) => Text(
              l10n.versionLine.replaceFirst(
                '{version}',
                '${info.version}'
                '${info.buildNumber.isEmpty ? '' : ' (build ${info.buildNumber})'}',
              ),
            ),
            loading: () => Text(l10n.versionLoading),
            error: (_, _) => Text(l10n.versionUnknown),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            Navigator.of(context).pop();
            await AppUpdateSettingsDialog.show(context);
          },
        ),
        if (Platform.isAndroid) ...[
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.widgets_outlined),
            title: Text(l10n.homeWidgetTitle),
            subtitle: Text(l10n.homeWidgetSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              Navigator.of(context).pop();
              final supported = await AndroidHomeWidgetBridge.isPinSupported();
              if (!context.mounted) return;
              if (supported) {
                await AndroidHomeWidgetBridge.requestPin();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.homeWidgetPinUnsupported)),
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
        const SizedBox(height: 16),
        const AppLanguageSettingsSection(),
        const SizedBox(height: 16),
        const AppAboutFooter(compact: true),
        if (!authConfigured) ...[
          const SizedBox(height: 12),
          Text(
            l10n.supabaseNotConfigured,
            style: TextStyle(color: theme.colorScheme.secondary),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            AuthDisplay.accountSummary(
              l10n,
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
