import 'package:mya/domain/entities/auth_user.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';

/// Libellés FR pour l'état d'authentification (D13).
abstract final class AuthDisplay {
  static String accountSummary(AuthUser? user, {required bool isConfigured}) {
    if (!isConfigured) {
      return 'Sync cloud non configurée';
    }
    if (user == null) {
      return 'Mode local — non connecté';
    }
    final label = user.email ?? user.displayName;
    if (label != null && label.isNotEmpty) {
      return 'Connecté : $label';
    }
    return 'Connecté';
  }

  static String trayMenuLabel(AuthUser? user, {required bool isConfigured}) {
    if (!isConfigured) {
      return 'Compte : sync non configurée…';
    }
    if (user == null) {
      return 'Se connecter…';
    }
    final label = user.email ?? user.displayName ?? 'Compte';
    if (label.length <= 28) {
      return 'Compte : $label…';
    }
    return 'Compte : ${label.substring(0, 25)}…';
  }

  static String providerLabel(MyaAuthProvider provider) {
    return switch (provider) {
      MyaAuthProvider.google => 'Continuer avec Google',
      MyaAuthProvider.apple => 'Continuer avec Apple',
      MyaAuthProvider.microsoft => 'Continuer avec Microsoft',
    };
  }
}
