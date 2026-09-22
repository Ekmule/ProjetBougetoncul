import 'package:flutter_test/flutter_test.dart';
import 'package:mya/application/bubble/bubble_appearance.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/core/constants/window_constants.dart';

void main() {
  test('BubbleAppearance expose le chemin asset de l\'icône', () {
    const appearance = BubbleAppearance(iconId: 'icon02');
    expect(appearance.assetPath, 'assets/icons/Icon02.png');
  });

  test('BubbleIconCatalog resolve les ids inconnus vers icon01', () {
    expect(BubbleIconCatalog.resolve('unknown').id, 'icon01');
    expect(BubbleIconCatalog.resolve('icon03').assetPath, 'assets/icons/Icon03.png');
  });

  test('bubbleSizeStep couvre la plage min-max', () {
    final steps =
        ((WindowConstants.maxBubbleSize - WindowConstants.minBubbleSize) /
                WindowConstants.bubbleSizeStep)
            .round();

    expect(steps, greaterThan(0));
    expect(
      WindowConstants.minBubbleSize + steps * WindowConstants.bubbleSizeStep,
      WindowConstants.maxBubbleSize,
    );
  });
}
