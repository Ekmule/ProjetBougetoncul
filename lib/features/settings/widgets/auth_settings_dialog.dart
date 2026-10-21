import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_exception.dart';
import 'package:mya/application/authentication/auth_display.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/application/sync/sync_status_provider.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';
import 'package:mya/features/shared/widgets/cloud_sync_badge.dart';
import 'package:mya/l10n/app_locale_code.dart';
import 'package:mya/l10n/mya_localizations.dart';

/// Connexion / déconnexion OAuth Supabase (D13).
class AuthSettingsDialog extends ConsumerStatefulWidget {
  const AuthSettingsDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const AuthSettingsDialog(),
    );
  }

  @override
  ConsumerState<AuthSettingsDialog> createState() => _AuthSettingsDialogState();
}

class _AuthSettingsDialogState extends ConsumerState<AuthSettingsDialog> {
  String? _error;
  String? _info;
  bool _busy = false;

  Future<void> _signIn(MyaAuthProvider provider) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
      _info = Platform.isAndroid ? l10n.authSignInAndroid : l10n.authSignInDesktop;
    });

    try {
      await ref.read(authServiceProvider).signInWithProvider(
            provider,
            locale: AppLocaleCode.parse(
              Localizations.localeOf(context).languageCode,
            ),
          );
      if (!mounted) return;
      if (Platform.isAndroid && ref.read(authUserProvider).value != null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {
        _info = l10n.authFinishInBrowser;
      });
    } on AuthNotConfiguredException catch (error) {
      setState(() => _error = error.message);
    } on AuthSignInException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });

    try {
      await ref.read(authServiceProvider).signOut();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      setState(() => _error = context.l10n.authSignOutFailed);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final configured = ref.watch(authConfiguredProvider);
    final authAsync = ref.watch(authUserProvider);
    final user = authAsync.value;
    final syncSnapshot = ref.watch(cloudSyncStatusProvider);

    ref.listen(authUserProvider, (previous, next) {
      final signedIn = next.value != null;
      final wasSignedIn = previous?.value != null;
      if (signedIn && !wasSignedIn && mounted) {
        Navigator.of(context).pop(true);
      }
    });

    return AlertDialog(
      title: Text(l10n.authDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AuthDisplay.accountSummary(l10n, user, isConfigured: configured),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (syncSnapshot.showsConnectedBadge) ...[
              const SizedBox(height: 8),
              CloudSyncStatusChip(snapshot: syncSnapshot),
            ],
            const SizedBox(height: 12),
            Text(l10n.authDialogBody),
            if (!configured) ...[
              const SizedBox(height: 12),
              Text(
                l10n.authNoSupabaseBuild,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
            if (configured && user == null) ...[
              const SizedBox(height: 16),
              for (final provider in MyaAuthProvider.supportedInUi)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _signIn(provider),
                    child: Text(AuthDisplay.providerLabel(l10n, provider)),
                  ),
                ),
            ],
            if (configured && user != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _busy ? null : _signOut,
                child: Text(l10n.authSignOut),
              ),
            ],
            if (_info != null) ...[
              const SizedBox(height: 12),
              Text(_info!, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
