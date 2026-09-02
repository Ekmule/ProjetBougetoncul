import 'package:equatable/equatable.dart';

/// Utilisateur authentifié — indépendant de Supabase (domaine pur).
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;

  @override
  List<Object?> get props => [id, email, displayName];
}
