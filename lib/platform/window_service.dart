import 'package:flutter/material.dart';
import 'package:mya/application/bubble/bubble_position.dart';

/// Contrôle la fenêtre native (pastille, panneau, Always-on-Top).
///
/// Les widgets ne doivent jamais appeler window_manager directement.
abstract class WindowService {
  Future<void> initializeBubbleWindow({
    Offset? initialPosition,
    BubbleAnchor? initialAnchor,
    String? initialDisplayId,
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

  Future<List<BubbleDisplay>> getDisplays();

  Future<Offset> moveToAnchor(BubbleAnchor anchor, {String? displayId});

  Future<void> beginFreeMove();

  Future<void> updateFreeMove();

  Future<Offset> endFreeMove();

  Future<void> hide();

  Future<void> show();

  Future<Offset> getPosition();

  Future<void> setPosition(Offset position);
}
