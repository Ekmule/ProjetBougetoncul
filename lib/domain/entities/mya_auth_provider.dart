/// Fournisseurs OAuth supportés par MYA (ADR-005).
enum MyaAuthProvider {
  google,
  apple,
  microsoft;

  /// Fournisseurs proposés dans l'UI (Windows MVP : Google uniquement).
  static const supportedInUi = [MyaAuthProvider.google];
}
