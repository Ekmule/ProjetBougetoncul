/// Supabase non configuré (pas de clés au build).
class AuthNotConfiguredException implements Exception {
  const AuthNotConfiguredException([
    this.message =
        'La synchronisation cloud n\'est pas configurée sur cette build.',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Échec de connexion OAuth ou réseau.
class AuthSignInException implements Exception {
  const AuthSignInException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
