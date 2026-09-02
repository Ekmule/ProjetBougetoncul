import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:mya/domain/entities/auth_user.dart';

/// Mappe un utilisateur Supabase vers l'entité domaine.
abstract final class AuthUserMapper {
  static AuthUser? fromSupabaseUser(User? user) {
    if (user == null) return null;

    final metadata = user.userMetadata;
    final displayName = _readString(metadata, 'full_name') ??
        _readString(metadata, 'name') ??
        _readString(metadata, 'display_name');

    return AuthUser(
      id: user.id,
      email: user.email,
      displayName: displayName,
    );
  }

  static String? _readString(Map<String, dynamic>? map, String key) {
    final value = map?[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }
}
