/// Constantes OAuth Supabase (D13).
abstract final class AuthConstants {
  /// Schéma URI enregistré sur Windows pour le retour OAuth.
  static const oauthScheme = 'com.mya.app';

  /// Hôte du deep link — doit figurer dans Supabase → Auth → Redirect URLs.
  static const oauthHost = 'login-callback';

  /// URL complète passée à `signInWithOAuth`.
  static const oauthRedirectUrl = '$oauthScheme://$oauthHost/';
}
