import 'package:mya/application/authentication/auth_exception.dart';
import 'package:mya/domain/entities/auth_user.dart';
import 'package:mya/domain/entities/mya_auth_provider.dart';

/// Authentification Supabase — couche application (D13).
abstract class AuthService {
  /// `false` si Supabase n'a pas été initialisé (build sans clés).
  bool get isConfigured;

  /// Session courante (null = mode local).
  AuthUser? get currentUser;

  /// Flux réactif de connexion / déconnexion.
  Stream<AuthUser?> get authStateChanges;

  /// Ouvre le navigateur OAuth ; la session arrive via deep link.
  Future<void> signInWithProvider(MyaAuthProvider provider);

  /// Déconnecte et efface la session persistée.
  Future<void> signOut();
}

/// Stub utilisé quand Supabase n'est pas configuré — l'app reste 100 % locale.
class NoOpAuthService implements AuthService {
  const NoOpAuthService();

  @override
  bool get isConfigured => false;

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthUser?> get authStateChanges => Stream.value(null);

  @override
  Future<void> signInWithProvider(MyaAuthProvider provider) async {
    throw const AuthNotConfiguredException();
  }

  @override
  Future<void> signOut() async {}
}
