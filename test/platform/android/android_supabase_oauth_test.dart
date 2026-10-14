import 'package:flutter_test/flutter_test.dart';
import 'package:mya/platform/android/android_supabase_oauth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('mapSupabaseAuthError traduit flow_state_already_used', () {
    final message = mapSupabaseAuthError(
      AuthException(
        'State has already been used',
        code: 'flow_state_already_used',
      ),
    );

    expect(message, contains('déjà été utilisée'));
  });

  test('mapSupabaseAuthError traduit code verifier manquant', () {
    final message = mapSupabaseAuthError(
      const AuthException('Code verifier could not be found in local storage.'),
    );

    expect(message, contains('expirée'));
  });

  test('mapAuthFailureMessage traduit erreur DNS', () {
    final message = mapAuthFailureMessage(
      Exception(
        "Failed host lookup: 'veyatfdofzwghbqhufcw.supabase.co'",
      ),
    );

    expect(message, contains('Connexion réseau impossible'));
  });
}
