import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/authentication/auth_service.dart';
import 'package:mya/domain/entities/auth_user.dart';

/// Service d'authentification — surchargé au bootstrap.
final authServiceProvider = Provider<AuthService>((ref) {
  throw UnimplementedError(
    'authServiceProvider must be overridden during bootstrap.',
  );
});

/// Session utilisateur courante (null = mode local).
final authUserProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Indique si Supabase Auth est disponible sur cette build.
final authConfiguredProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider).isConfigured;
});
