import 'package:mya/platform/tray_service.dart';

/// Implémentation neutre — plateformes sans tray.
class NoOpTrayService implements TrayService {
  const NoOpTrayService();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> updateMenu() async {}

  @override
  Future<void> dispose() async {}
}
