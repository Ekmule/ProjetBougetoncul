import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_exception.dart';
import 'package:mya/application/authentication/auth_display.dart';
import 'package:mya/application/authentication/auth_providers.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';

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
    setState(() {
      _busy = true;
      _error = null;
      _info =
          'Un navigateur va s\'ouvrir. Revenez ici après la connexion.';
    });

    try {
      await ref.read(authServiceProvider).signInWithProvider(provider);
      if (!mounted) return;
      setState(() {
        _info =
            'Terminez la connexion dans le navigateur, puis revenez à MYA.';
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
      setState(() => _error = 'Déconnexion impossible.');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final configured = ref.watch(authConfiguredProvider);
    final authAsync = ref.watch(authUserProvider);
    final user = authAsync.value;

    ref.listen(authUserProvider, (previous, next) {
      final signedIn = next.value != null;
      final wasSignedIn = previous?.value != null;
      if (signedIn && !wasSignedIn && mounted) {
        Navigator.of(context).pop(true);
      }
    });

    return AlertDialog(
      title: const Text('Compte et synchronisation'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AuthDisplay.accountSummary(
                user,
                isConfigured: configured,
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'MYA fonctionne sans compte. Connectez-vous uniquement '
              'pour synchroniser vos tâches entre appareils (D14).',
            ),
            if (!configured) ...[
              const SizedBox(height: 12),
              Text(
                'Cette build n\'a pas de clés Supabase. '
                'Voir docs/database.md pour la configuration.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
            if (configured && user == null) ...[
              const SizedBox(height: 16),
              for (final provider in MyaAuthProvider.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _signIn(provider),
                    child: Text(AuthDisplay.providerLabel(provider)),
                  ),
                ),
            ],
            if (configured && user != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: _busy ? null : _signOut,
                child: const Text('Se déconnecter'),
              ),
            ],
            if (_info != null) ...[
              const SizedBox(height: 12),
              Text(
                _info!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
