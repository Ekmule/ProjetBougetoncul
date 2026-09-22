import 'package:flutter/material.dart';

/// Constantes liées à la fenêtre pastille Windows.
///
/// Centralise les tailles pour éviter les valeurs magiques dispersées dans le code.
class WindowConstants {
  WindowConstants._();

  /// Taille de la pastille seule (cercle rouge).
  static const double defaultBubbleSize = 64;
  static const double minBubbleSize = 48;
  static const double maxBubbleSize = 96;
  static const double bubbleSizeStep = 8;

  /// Alias historique — préférer [defaultBubbleSize] ou la valeur persistée.
  static const double bubbleSize = defaultBubbleSize;

  /// Couleur opaque de la pastille — évite les bugs de transparence Windows.
  static const Color bubbleColor = Color(0xFFE53935);

  /// Fond visuellement transparent mais non nul pour conserver le hit-test
  /// natif Windows sur toute la petite fenêtre de la pastille.
  static const Color bubbleHitTestColor = Color(0x01000000);

  /// Aperçu compact au survol (3 tâches visibles, liste scrollable — ADR-018).
  static const double previewWidth = 280;
  static const double previewHeight = 260;

  /// Panneau complet avec toutes les catégories.
  static const double panelWidth = 320;
  static const double panelHeight = 520;

  /// Délai avant expansion au survol (ADR-018).
  static const Duration hoverDelay = Duration(milliseconds: 400);

  /// Distance en pixels pour accrocher la pastille à un bord.
  static const double snapThreshold = 40;

  /// Marge par rapport au bord de l'écran.
  static const double screenMargin = 16;
}
