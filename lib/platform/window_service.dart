import 'package:flutter/material.dart';

/// Contrôle la fenêtre native (pastille, panneau, Always-on-Top).
///
/// Les widgets ne doivent jamais appeler window_manager directement.
abstract class WindowService {
  Future<void> initializeBubbleWindow({
    Offset? initialPosition,
    bool alwaysOnTop = true,
  });

  Future<void> applyViewMode({
    required bool isBubble,
    required bool isPreview,
    required bool isPanel,
  });

  /// Redimensionne la pastille (mode bulle uniquement).
  Future<void> applyBubbleSize(double size);

  Future<void> setAlwaysOnTop(bool enabled);

  Future<void> moveBy(Offset delta);

  Future<void> snapToEdgeIfNeeded();

  Future<void> hide();

  Future<void> show();

  Future<Offset> getPosition();

  Future<void> setPosition(Offset position);
}
