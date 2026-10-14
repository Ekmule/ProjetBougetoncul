import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/updates/app_release_info.dart';
import 'package:mya/application/updates/update_providers.dart';

/// Propose d'installer une release GitHub détectée.
class AppUpdateDialog extends ConsumerWidget {
  const AppUpdateDialog({
    super.key,
    required this.release,
    this.allowDismiss = true,
  });

  final AppReleaseInfo release;
  final bool allowDismiss;

  static Future<void> show(
    BuildContext context, {
    required AppReleaseInfo release,
    bool allowDismiss = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: allowDismiss,
      builder: (context) =>
          AppUpdateDialog(release: release, allowDismiss: allowDismiss),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updateCheckProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Mise à jour disponible'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MYA ${release.version.displayName} est disponible.',
            style: theme.textTheme.titleSmall,
          ),
          if (release.releaseNotes != null) ...[
            const SizedBox(height: 12),
            Text(release.releaseNotes!, style: theme.textTheme.bodySmall),
          ],
          if (updateState.downloading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(value: updateState.progress),
            const SizedBox(height: 8),
            const Text('Téléchargement en cours…'),
          ],
          if (updateState.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              updateState.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        if (allowDismiss)
          TextButton(
            onPressed: updateState.downloading
                ? null
                : () async {
                    await ref
                        .read(updateCheckProvider.notifier)
                        .dismissAvailableUpdate();
                    if (context.mounted) Navigator.of(context).pop();
                  },
            child: const Text('Plus tard'),
          ),
        FilledButton(
          onPressed: updateState.downloading
              ? null
              : () => ref
                    .read(updateCheckProvider.notifier)
                    .installAvailableUpdate(),
          child: const Text('Installer'),
        ),
      ],
    );
  }
}

/// Dialogue manuel depuis les paramètres.
class AppUpdateSettingsDialog extends ConsumerStatefulWidget {
  const AppUpdateSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const AppUpdateSettingsDialog(),
    );
  }

  @override
  ConsumerState<AppUpdateSettingsDialog> createState() =>
      _AppUpdateSettingsDialogState();
}

class _AppUpdateSettingsDialogState
    extends ConsumerState<AppUpdateSettingsDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        ref
            .read(updateCheckProvider.notifier)
            .checkForUpdates(userInitiated: true),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateCheckProvider);
    final theme = Theme.of(context);
    final current = updateState.currentVersion?.displayName;

    ref.listen(updateCheckProvider, (previous, next) {
      final release = next.availableRelease;
      if (release == null || !mounted) return;
      if (previous?.availableRelease?.versionKey == release.versionKey) {
        return;
      }
      Navigator.of(context).pop();
      unawaited(
        AppUpdateDialog.show(context, release: release, allowDismiss: true),
      );
    });

    return AlertDialog(
      title: const Text('Mises à jour'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (current != null) Text('Version installée : $current'),
          const SizedBox(height: 12),
          if (updateState.checking)
            const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Recherche sur GitHub Releases…'),
              ],
            ),
          if (updateState.infoMessage != null) Text(updateState.infoMessage!),
          if (updateState.errorMessage != null)
            Text(
              updateState.errorMessage!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        FilledButton(
          onPressed: updateState.checking
              ? null
              : () => ref
                    .read(updateCheckProvider.notifier)
                    .checkForUpdates(userInitiated: true),
          child: const Text('Revérifier'),
        ),
      ],
    );
  }
}
