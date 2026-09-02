import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:mya/data/remote/auth_user_mapper.dart';

void main() {
  test('fromSupabaseUser mappe email et nom', () {
    final user = User(
      id: 'user-1',
      appMetadata: {},
      userMetadata: {'full_name': 'Alice MYA'},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00Z',
      email: 'alice@example.com',
    );

    final mapped = AuthUserMapper.fromSupabaseUser(user);

    expect(mapped?.id, 'user-1');
    expect(mapped?.email, 'alice@example.com');
    expect(mapped?.displayName, 'Alice MYA');
  });

  test('fromSupabaseUser retourne null si absent', () {
    expect(AuthUserMapper.fromSupabaseUser(null), isNull);
  });
}
