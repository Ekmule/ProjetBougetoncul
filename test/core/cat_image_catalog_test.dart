import 'package:flutter_test/flutter_test.dart';
import 'package:mya/core/cat_image_catalog.dart';

void main() {
  test('change de photo chaque jour et recommence après huit jours', () {
    final firstDay = DateTime(2026, 11, 10);

    expect(
      CatImageCatalog.forDate(firstDay),
      isNot(CatImageCatalog.forDate(firstDay.add(const Duration(days: 1)))),
    );
    expect(
      CatImageCatalog.forDate(firstDay),
      CatImageCatalog.forDate(firstDay.add(const Duration(days: 8))),
    );
  });

  test('retourne toujours un asset déclaré dans le catalogue', () {
    final asset = CatImageCatalog.forDate(DateTime(2026, 1, 1));

    expect(CatImageCatalog.assetPaths, contains(asset));
  });
}
