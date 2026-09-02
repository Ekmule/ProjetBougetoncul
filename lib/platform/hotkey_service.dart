import 'package:hotkey_manager/hotkey_manager.dart';

/// Raccourcis clavier globaux (Windows) ou no-op sur les autres plateformes.
abstract class HotkeyService {
  Future<void> registerQuickAdd({
    required HotKey hotKey,
    required void Function() onTriggered,
  });

  Future<void> dispose();
}

/// Implémentation vide pour Android/iOS (raccourcis globaux non supportés).
class NoOpHotkeyService implements HotkeyService {
  const NoOpHotkeyService();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> registerQuickAdd({
    required HotKey hotKey,
    required void Function() onTriggered,
  }) async {}
}
