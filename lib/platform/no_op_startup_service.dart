import 'package:mya/platform/startup_service.dart';

/// Implémentation neutre — plateformes sans démarrage auto.
class NoOpStartupService implements StartupService {
  const NoOpStartupService();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<void> setEnabled(bool enabled) async {}
}
