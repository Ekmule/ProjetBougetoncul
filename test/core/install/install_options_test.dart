import 'package:flutter_test/flutter_test.dart';
import 'package:mya/core/constants/bubble_icon_catalog.dart';
import 'package:mya/core/install/install_options.dart';

void main() {
  test('InstallOptions parse startup, cloud sync et icône', () {
    const options = InstallOptions(
      startupEnabled: true,
      preferCloudSync: true,
      bubbleIconId: 'icon02',
    );

    expect(options.startupEnabled, isTrue);
    expect(options.preferCloudSync, isTrue);
    expect(options.bubbleIconId, 'icon02');
  });

  test('InstallOptions utilise icon01 par défaut', () {
    const options = InstallOptions();
    expect(options.bubbleIconId, BubbleIconCatalog.defaultIconId);
  });
}
