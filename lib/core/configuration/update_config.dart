/// Configuration des mises à jour distantes (GitHub Releases).
abstract final class UpdateConfig {
  static const enabled = bool.fromEnvironment(
    'UPDATE_CHECK_ENABLED',
    defaultValue: true,
  );

  static const githubOwner = String.fromEnvironment(
    'UPDATE_GITHUB_OWNER',
    defaultValue: 'Ekmule',
  );

  static const githubRepo = String.fromEnvironment(
    'UPDATE_GITHUB_REPO',
    defaultValue: 'ProjetBougetoncul',
  );

  static const checkIntervalHours = int.fromEnvironment(
    'UPDATE_CHECK_INTERVAL_HOURS',
    defaultValue: 24,
  );

  static bool get isConfigured =>
      enabled && githubOwner.isNotEmpty && githubRepo.isNotEmpty;
}
