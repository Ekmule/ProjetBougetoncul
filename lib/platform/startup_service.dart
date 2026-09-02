/// Démarrage automatique avec Windows (ADR-011).
abstract class StartupService {
  Future<void> initialize();

  Future<bool> isEnabled();

  Future<void> setEnabled(bool enabled);
}
