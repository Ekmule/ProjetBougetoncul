import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/application/bubble/bubble_appearance.dart';
import 'package:mya/application/bubble/bubble_ui_notifier.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/core/constants/window_constants.dart';
import 'package:mya/data/providers/device_settings_providers.dart';
import 'package:mya/platform/platform_providers.dart';

/// Taille et icône de la pastille — persistance + application fenêtre.
class BubbleAppearanceNotifier extends Notifier<BubbleAppearance> {
  @override
  BubbleAppearance build() {
    final settings = ref.read(deviceSettingsStoreProvider).readBubbleSettings();
    return BubbleAppearance(
      size: settings.bubbleSize,
      iconId: settings.bubbleIconId,
    );
  }

  Future<void> setSize(double size) async {
    final clamped = size.clamp(
      WindowConstants.minBubbleSize,
      WindowConstants.maxBubbleSize,
    );
    if (clamped == state.size) return;

    state = state.copyWith(size: clamped);
    await ref.read(deviceSettingsStoreProvider).saveBubbleSize(clamped);
    await _applyBubbleWindowSizeIfNeeded();
  }

  Future<void> setIconId(String iconId) async {
    final resolved = BubbleIconCatalog.resolve(iconId).id;
    if (resolved == state.iconId) return;

    state = state.copyWith(iconId: resolved);
    await ref.read(deviceSettingsStoreProvider).saveBubbleIconId(resolved);
  }

  Future<void> _applyBubbleWindowSizeIfNeeded() async {
    final ui = ref.read(bubbleUiProvider);
    if (ui.isVisible && ui.viewMode == BubbleViewMode.bubble) {
      await ref.read(windowServiceProvider).applyBubbleSize(state.size);
    }
  }
}

final bubbleAppearanceProvider =
    NotifierProvider<BubbleAppearanceNotifier, BubbleAppearance>(
      BubbleAppearanceNotifier.new,
    );
