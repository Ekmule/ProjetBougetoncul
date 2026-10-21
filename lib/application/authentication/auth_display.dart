import 'package:mya/domain/entities/auth_user.dart';

import 'package:mya/domain/entities/mya_auth_provider.dart';

import 'package:mya/l10n/mya_localizations.dart';



/// Libellés pour l'état d'authentification (D13).

abstract final class AuthDisplay {

  static String accountSummary(

    MyaLocalizations l10n,

    AuthUser? user, {

    required bool isConfigured,

  }) {

    if (!isConfigured) {

      return l10n.authCloudNotConfigured;

    }

    if (user == null) {

      return l10n.authLocalNotSignedIn;

    }

    final label = user.email ?? user.displayName;

    if (label != null && label.isNotEmpty) {

      return l10n.authAccountSummary(label, isConfigured: true);

    }

    return l10n.authSignedIn;

  }



  static String trayMenuLabel(

    MyaLocalizations l10n,

    AuthUser? user, {

    required bool isConfigured,

  }) {

    if (!isConfigured) {

      return l10n.authTrayNotConfigured;

    }

    if (user == null) {

      return l10n.authTraySignIn;

    }

    final label = user.email ?? user.displayName ?? l10n.authConnectedAccount;

    return l10n.authTrayLabel(label, isConfigured: true);

  }



  static String providerLabel(MyaLocalizations l10n, MyaAuthProvider provider) {

    return l10n.oauthProviderLabel(provider);

  }

}


