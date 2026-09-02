import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/bubble/bubble_ui_notifier.dart';
import 'package:mya/data/providers/device_settings_providers.dart';

/// Gère le mode « toujours au-dessus » — état UI + persistance (D11).
class AlwaysOnTopService {
  const AlwaysOnTopService(this._ref);

  final Ref _ref;

  bool get isEnabled => _ref.read(bubbleUiProvider).alwaysOnTop;

  Future<void> setEnabled(bool enabled) async {
    if (enabled == isEnabled) return;

    _ref.read(bubbleUiProvider.notifier).setAlwaysOnTop(enabled);
    await _ref.read(deviceSettingsStoreProvider).saveAlwaysOnTop(enabled);
  }

  Future<void> toggle() async {
    await setEnabled(!isEnabled);
  }
}

final alwaysOnTopServiceProvider = Provider<AlwaysOnTopService>((ref) {
  return AlwaysOnTopService(ref);
});
