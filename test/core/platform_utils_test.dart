import 'package:flutter_test/flutter_test.dart';
import 'package:mya/core/utils/platform_utils.dart';

void main() {
  test('PlatformUtils.isDesktop est cohérent sur la plateforme de test', () {
    expect(PlatformUtils.isMobile || PlatformUtils.isDesktop, isTrue);
  });
}
