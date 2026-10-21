import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:mya/application/authentication/auth_exception.dart';
import 'package:mya/l10n/mya_localizations.dart';
import 'package:mya/core/constants/auth_constants.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// OAuth Supabase via flutter_web_auth_2 (Auth Tab Android, D16 fix).
abstract final class AndroidSupabaseOAuth {
  static Future<void> signIn(
    GoTrueClient auth,
    MyaAuthProvider provider, {
    required MyaLocalizations l10n,
  }) async {
    final oauthProvider = _toOAuthProvider(provider);
    final providerName = l10n.oauthProviderLabel(provider);

    try {
      final oauthUrl = await auth.getOAuthSignInUrl(
        provider: oauthProvider,
        redirectTo: AuthConstants.oauthRedirectUrl,
      );

      final callback = await FlutterWebAuth2.authenticate(
        url: oauthUrl.url,
        callbackUrlScheme: AuthConstants.oauthScheme,
        options: const FlutterWebAuth2Options(
          // Honor / Firefox en navigateur externe affiche souvent la page HTML
          // « Found » au lieu de renvoyer vers com.mya.app — Chrome Custom Tabs
          // capture le redirect correctement.
          customTabsPackageOrder: [
            'com.android.chrome',
            'com.chrome.beta',
            'com.chrome.dev',
            'com.microsoft.emmx',
            'com.sec.android.app.sbrowser',
          ],
          preferEphemeral: false,
        ),
      );

      await auth.getSessionFromUrl(Uri.parse(callback));

      if (auth.currentSession == null) {
        throw AuthSignInException(
          'Connexion $providerName terminée mais aucune session n\'a été créée.',
        );
      }
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        throw const AuthSignInException('Connexion annulée.');
      }
      throw AuthSignInException(
        'Connexion $providerName impossible : ${error.message ?? error.code}.',
        cause: error,
      );
    } on AuthException catch (error) {
      throw AuthSignInException(mapSupabaseAuthError(error), cause: error);
    } on AuthSignInException {
      rethrow;
    } catch (error) {
      throw AuthSignInException(
        mapAuthFailureMessage(error),
        cause: error,
      );
    }
  }

  static OAuthProvider _toOAuthProvider(MyaAuthProvider provider) {
    return switch (provider) {
      MyaAuthProvider.google => OAuthProvider.google,
      MyaAuthProvider.apple => OAuthProvider.apple,
      MyaAuthProvider.microsoft => OAuthProvider.azure,
    };
  }
}

/// Message utilisateur pour les erreurs réseau / Supabase Auth.
String mapAuthFailureMessage(Object error) {
  final text = error.toString();
  if (text.contains('Failed host lookup') ||
      text.contains('SocketException') ||
      text.contains('Network is unreachable') ||
      text.contains('No address associated with hostname')) {
    return 'Connexion réseau impossible vers Supabase. '
        'Vérifiez le Wi‑Fi ou les données mobiles, puis réessayez.';
  }
  return text;
}

/// Message utilisateur pour les erreurs Supabase Auth.
String mapSupabaseAuthError(AuthException error) {
  final code = error.code ?? '';
  final description = error.message;

  if (code == 'flow_state_already_used') {
    return 'Cette tentative de connexion a déjà été utilisée. '
        'Effacez les données MYA puis réessayez une seule fois.';
  }
  if (description.contains('Code verifier could not be found')) {
    return 'Session de connexion expirée. Relancez la connexion sans quitter MYA.';
  }
  if (code == 'invalid_request' && description.contains('State')) {
    return 'État OAuth invalide. Effacez les données MYA et réessayez.';
  }
  if (description.isNotEmpty) return description;
  return 'Connexion impossible (${code.isEmpty ? 'erreur inconnue' : code}).';
}
