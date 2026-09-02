import 'dart:async';

import 'package:mya/platform/tray_service.dart';
import 'package:tray_manager/tray_manager.dart';

/// Menu contextuel tray Windows via tray_manager (ADR-010).
class WindowsTrayService with TrayListener implements TrayService {
  WindowsTrayService(this._actions, this._readMenuState);

  final TrayActions _actions;
  final TrayMenuState Function() _readMenuState;
  var _initialized = false;

  static const _iconPath = 'assets/icons/tray_icon.ico';

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    await trayManager.setIcon(_iconPath);
    await trayManager.setToolTip('MYA');
    trayManager.addListener(this);
    await updateMenu();
    _initialized = true;
  }

  @override
  Future<void> updateMenu() async {
    if (!_initialized) return;

    final state = _readMenuState();
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem(key: 'open', label: 'Ouvrir MYA'),
          MenuItem(
            key: 'toggle_visible',
            label: state.bubbleVisible
                ? 'Masquer la pastille'
                : 'Afficher la pastille',
          ),
          MenuItem(
            key: 'toggle_aot',
            label: state.alwaysOnTop
                ? 'Toujours au-dessus : activé'
                : 'Toujours au-dessus : désactivé',
          ),
          MenuItem(
            key: 'toggle_startup',
            label: state.startupEnabled
                ? 'Démarrage avec Windows : activé'
                : 'Démarrage avec Windows : désactivé',
          ),
          MenuItem(
            key: 'configure_hotkey',
            label: 'Raccourci : ${state.hotkeyLabel}…',
          ),
          MenuItem(
            key: 'configure_account',
            label: state.authLabel,
          ),
          MenuItem.separator(),
          MenuItem(key: 'quit', label: 'Quitter'),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    trayManager.removeListener(this);
  }

  @override
  void onTrayIconMouseDown() {
    _actions.openMya();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'open':
        _actions.openMya();
      case 'toggle_visible':
        _actions.toggleBubbleVisible();
      case 'toggle_aot':
        _actions.toggleAlwaysOnTop();
      case 'toggle_startup':
        unawaited(_toggleStartup());
        return;
      case 'configure_hotkey':
        _actions.configureHotkey();
        return;
      case 'configure_account':
        _actions.configureAccount();
        return;
      case 'quit':
        unawaited(_actions.quit());
        return;
    }
    unawaited(updateMenu());
  }

  Future<void> _toggleStartup() async {
    await _actions.toggleStartupEnabled();
    await updateMenu();
  }
}
