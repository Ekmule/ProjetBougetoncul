import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Position fixe de la pastille dans la zone de travail d'un écran.
enum BubbleAnchor {
  topLeft('En haut à gauche', -1, -1),
  topCenter('En haut au centre', 0, -1),
  topRight('En haut à droite', 1, -1),
  centerLeft('Au milieu à gauche', -1, 0),
  centerRight('Au milieu à droite', 1, 0),
  bottomLeft('En bas à gauche', -1, 1),
  bottomCenter('En bas au centre', 0, 1),
  bottomRight('En bas à droite', 1, 1);

  const BubbleAnchor(this.label, this.horizontal, this.vertical);

  final String label;
  final int horizontal;
  final int vertical;

  static BubbleAnchor? fromName(String? value) {
    for (final anchor in values) {
      if (anchor.name == value) return anchor;
    }
    return null;
  }
}

/// Écran disponible et zone dans laquelle MYA peut placer sa fenêtre.
class BubbleDisplay {
  const BubbleDisplay({
    required this.id,
    required this.name,
    required this.workArea,
    required this.isPrimary,
  });

  final String id;
  final String name;
  final Rect workArea;
  final bool isPrimary;
}

/// Calculs purs de positionnement, indépendants des APIs Windows.
abstract final class BubblePositioning {
  static Offset anchoredPosition({
    required Rect workArea,
    required Size windowSize,
    required BubbleAnchor anchor,
    required double margin,
  }) {
    final left = workArea.left + margin;
    final right = workArea.right - windowSize.width - margin;
    final top = workArea.top + margin;
    final bottom = workArea.bottom - windowSize.height - margin;

    final x = switch (anchor.horizontal) {
      -1 => left,
      0 => workArea.left + (workArea.width - windowSize.width) / 2,
      _ => right,
    };
    final y = switch (anchor.vertical) {
      -1 => top,
      0 => workArea.top + (workArea.height - windowSize.height) / 2,
      _ => bottom,
    };

    return clampToWorkArea(
      Offset(x, y),
      windowSize: windowSize,
      workArea: workArea,
      margin: margin,
    );
  }

  static Offset clampToWorkArea(
    Offset position, {
    required Size windowSize,
    required Rect workArea,
    double margin = 0,
  }) {
    final minX = workArea.left + margin;
    final maxX = math.max(minX, workArea.right - windowSize.width - margin);
    final minY = workArea.top + margin;
    final maxY = math.max(minY, workArea.bottom - windowSize.height - margin);

    return Offset(position.dx.clamp(minX, maxX), position.dy.clamp(minY, maxY));
  }

  static BubbleDisplay nearestDisplay(
    Offset point,
    List<BubbleDisplay> displays,
  ) {
    assert(displays.isNotEmpty);
    for (final display in displays) {
      if (display.workArea.contains(point)) return display;
    }

    return displays.reduce((current, candidate) {
      final currentDistance = _squaredDistanceToRect(point, current.workArea);
      final candidateDistance = _squaredDistanceToRect(
        point,
        candidate.workArea,
      );
      return candidateDistance < currentDistance ? candidate : current;
    });
  }

  static double _squaredDistanceToRect(Offset point, Rect rect) {
    final dx = point.dx < rect.left
        ? rect.left - point.dx
        : point.dx > rect.right
        ? point.dx - rect.right
        : 0.0;
    final dy = point.dy < rect.top
        ? rect.top - point.dy
        : point.dy > rect.bottom
        ? point.dy - rect.bottom
        : 0.0;
    return dx * dx + dy * dy;
  }
}
