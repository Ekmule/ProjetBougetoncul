/// Configuration Supabase lue via `--dart-define` ou `--dart-define-from-file`.
abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const anonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// `true` quand les deux clés sont renseignées au build.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
