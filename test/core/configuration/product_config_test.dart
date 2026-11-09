import 'package:flutter_test/flutter_test.dart';
import 'package:mya/core/configuration/product_config.dart';

void main() {
  test('le produit par défaut reste MYA Complete', () {
    expect(ProductConfig.product, MyaProduct.complete);
    expect(ProductConfig.supportsCloud, isTrue);
    expect(ProductConfig.databaseName, 'mya');
    expect(ProductConfig.windowsMutexId, 'com.mya.app');
  });
}
