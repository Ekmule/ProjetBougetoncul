/// Mentions légales affichées dans l'application (éditeur / droits d'auteur).
abstract final class AppLegal {
  /// Raison sociale de l'auto-entreprise éditrice.
  static const publisherName = 'Zonakron édition';

  /// Année affichée dans le copyright (mise à jour manuelle si besoin).
  static const copyrightYear = 2026;

  static const appName = 'MYA';

  /// Ligne courte pour paramètres / pied de page.
  static String get copyrightLine =>
      '© $copyrightYear $publisherName. Tous droits réservés.';

  /// Texte « À propos » (informatif, pas un contrat).
  static String get aboutBlurb =>
      '$appName est édité par $publisherName. '
      'Le logiciel et ses éléments graphiques sont protégés par le droit '
      "d'auteur. L'utilisation est soumise à votre acceptation des conditions "
      'd\'utilisation du service cloud que vous configurez (ex. Supabase, Google).';
}
