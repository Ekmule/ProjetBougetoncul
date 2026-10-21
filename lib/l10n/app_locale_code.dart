import 'dart:ui';

/// Langues supportées (phase A — UI complète en étape suivante).
enum AppLocaleCode {
  en('en'),
  fr('fr');

  const AppLocaleCode(this.languageCode);

  final String languageCode;

  static AppLocaleCode parse(String? raw) {
    return switch (raw?.toLowerCase()) {
      'fr' => AppLocaleCode.fr,
      'en' => AppLocaleCode.en,
      _ => AppLocaleCode.en,
    };
  }

  /// Installations sans clé : français (historique). Android sans clé : anglais.
  static AppLocaleCode defaultWhenUnset({required bool android}) {
    return android ? AppLocaleCode.en : AppLocaleCode.fr;
  }

  Locale toFlutterLocale() => Locale(languageCode);
}
