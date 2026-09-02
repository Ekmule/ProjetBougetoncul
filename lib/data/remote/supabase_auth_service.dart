import 'package:mya/application/authentication/auth_exception.dart';
import 'package:mya/application/authentication/auth_service.dart';
import 'package:mya/core/constants/auth_constants.dart';
import 'package:mya/data/remote/auth_user_mapper.dart';
import 'package:mya/domain/entities/auth_user.dart' as domain;
import 'package:mya/domain/entities/mya_auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implémentation Supabase Auth (OAuth PKCE + deep link).
class SupabaseAuthService implements AuthService {
  SupabaseAuthService();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  @override
  bool get isConfigured => true;

  @override
  domain.AuthUser? get currentUser =>
      AuthUserMapper.fromSupabaseUser(_auth.currentUser);

  @override
  Stream<domain.AuthUser?> get authStateChanges async* {
    yield currentUser;
    yield* _auth.onAuthStateChange.map(
      (event) => AuthUserMapper.fromSupabaseUser(event.session?.user),
    );
  }

  @override
  Future<void> signInWithProvider(MyaAuthProvider provider) async {
    try {
      await _auth.signInWithOAuth(
        _toOAuthProvider(provider),
        redirectTo: AuthConstants.oauthRedirectUrl,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } on AuthException catch (error) {
      throw AuthSignInException(error.message, cause: error);
    } catch (error) {
      throw AuthSignInException(
        'Impossible d\'ouvrir la connexion ${AuthDisplayProvider.name(provider)}.',
        cause: error,
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  OAuthProvider _toOAuthProvider(MyaAuthProvider provider) {
    return switch (provider) {
      MyaAuthProvider.google => OAuthProvider.google,
      MyaAuthProvider.apple => OAuthProvider.apple,
      MyaAuthProvider.microsoft => OAuthProvider.azure,
    };
  }
}

/// Libellé court pour les messages d'erreur (évite import circulaire UI).
abstract final class AuthDisplayProvider {
  static String name(MyaAuthProvider provider) {
    return switch (provider) {
      MyaAuthProvider.google => 'Google',
      MyaAuthProvider.apple => 'Apple',
      MyaAuthProvider.microsoft => 'Microsoft',
    };
  }
}
