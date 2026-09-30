import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/bubble/bubble_position.dart';

void main() {
  const primary = BubbleDisplay(
    id: 'primary',
    name: 'Principal',
    workArea: Rect.fromLTWH(0, 0, 1920, 1040),
    isPrimary: true,
  );
  const secondary = BubbleDisplay(
    id: 'secondary',
    name: 'Secondaire',
    workArea: Rect.fromLTWH(-1280, 0, 1280, 984),
    isPrimary: false,
  );

  test('calcule les huit positions dans la zone de travail', () {
    const size = Size(64, 64);
    const margin = 16.0;

    expect(
      BubblePositioning.anchoredPosition(
        workArea: primary.workArea,
        windowSize: size,
        anchor: BubbleAnchor.topLeft,
        margin: margin,
      ),
      const Offset(16, 16),
    );
    expect(
      BubblePositioning.anchoredPosition(
        workArea: primary.workArea,
        windowSize: size,
        anchor: BubbleAnchor.topCenter,
        margin: margin,
      ),
      const Offset(928, 16),
    );
    expect(
      BubblePositioning.anchoredPosition(
        workArea: primary.workArea,
        windowSize: size,
        anchor: BubbleAnchor.bottomRight,
        margin: margin,
      ),
      const Offset(1840, 960),
    );
  });

  test('prend en charge les coordonnées négatives du second écran', () {
    final position = BubblePositioning.anchoredPosition(
      workArea: secondary.workArea,
      windowSize: const Size(64, 64),
      anchor: BubbleAnchor.centerLeft,
      margin: 16,
    );

    expect(position, const Offset(-1264, 460));
  });

  test('ramène une fenêtre hors écran dans la zone visible', () {
    final position = BubblePositioning.clampToWorkArea(
      const Offset(2200, -200),
      windowSize: const Size(320, 520),
      workArea: primary.workArea,
    );

    expect(position, const Offset(1600, 0));
  });

  test('sélectionne l’écran contenant ou le plus proche du curseur', () {
    final displays = [primary, secondary];

    expect(
      BubblePositioning.nearestDisplay(const Offset(-500, 300), displays).id,
      'secondary',
    );
    expect(
      BubblePositioning.nearestDisplay(const Offset(500, 300), displays).id,
      'primary',
    );
    expect(
      BubblePositioning.nearestDisplay(const Offset(-10, 1200), displays).id,
      'primary',
    );
  });
}
