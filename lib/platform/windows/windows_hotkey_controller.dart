import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:mya/platform/hotkey_service.dart';

/// Enregistre le raccourci global système via hotkey_manager (ADR-009, D12).
class WindowsHotkeyController implements HotkeyService {
  @override
  Future<void> registerQuickAdd({
    required HotKey hotKey,
    required void Function() onTriggered,
  }) async {
    await hotKeyManager.unregisterAll();

    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (_) => onTriggered(),
    );
  }

  @override
  Future<void> dispose() async {
    await hotKeyManager.unregisterAll();
  }
}
