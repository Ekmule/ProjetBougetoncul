import 'package:flutter/material.dart';
import 'package:mya/application/bubble/bubble_position.dart';

class WindowLayoutSnapshot {
  const WindowLayoutSnapshot({
    required this.size,
    required this.position,
    required this.wasBubble,
  });

  final Size size;
  final Offset position;
  final bool wasBubble;
}

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

  /// Agrandit temporairement la fenêtre pour afficher une super alerte.
  Future<WindowLayoutSnapshot> enterSuperAlertLayout(double screenFraction);

  /// Restaure la taille et la position précédant la super alerte.
  Future<void> restoreLayout(WindowLayoutSnapshot snapshot);

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
