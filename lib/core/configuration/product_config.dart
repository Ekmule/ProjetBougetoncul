import 'dart:io';

enum MyaProduct { complete, mobile, desktop }

/// Identité et capacités du produit sélectionné à la compilation.
///
/// Utiliser `--dart-define=MYA_PRODUCT=complete|mobile|desktop`.
abstract final class ProductConfig {
  static const rawProduct = String.fromEnvironment(
    'MYA_PRODUCT',
    defaultValue: 'complete',
  );

  static const supportsCloud = rawProduct == 'complete';
  static const supportsAndroid = rawProduct != 'desktop';
  static const supportsWindows = rawProduct != 'mobile';

  static MyaProduct get product => switch (rawProduct) {
    'complete' => MyaProduct.complete,
    'mobile' => MyaProduct.mobile,
    'desktop' => MyaProduct.desktop,
    _ => throw StateError('MYA_PRODUCT invalide : $rawProduct'),
  };

  static String get displayName => switch (product) {
    MyaProduct.complete => 'MYA Complete',
    MyaProduct.mobile => 'MYA Mobile',
    MyaProduct.desktop => 'MYA Desktop',
  };

  static String get productKey => product.name;
  static String get databaseName => switch (product) {
    MyaProduct.complete => 'mya',
    MyaProduct.mobile => 'mya_mobile',
    MyaProduct.desktop => 'mya_desktop',
  };
  static String get windowsMutexId => product == MyaProduct.complete
      ? 'com.mya.app'
      : 'com.mya.$productKey.app';
  static String get windowsNotificationId => windowsMutexId;
  static String get windowsNotificationGuid => switch (product) {
    MyaProduct.complete => 'A8C22B55-049E-422F-B30F-863694DE08C8',
    MyaProduct.desktop => 'D50F7A1E-2A37-4AA8-A79D-62AC5D11B74E',
    MyaProduct.mobile => 'BC881EF1-327E-491F-88ED-ECE317F57B68',
  };
  static String get installOptionsFolder =>
      product == MyaProduct.complete ? 'MYA' : displayName;
  static String get releaseTagPrefix => '$productKey-v';

  static String assetPrefixForCurrentPlatform() {
    if (Platform.isWindows) return 'MYA-$displayNameSuffix-Setup-';
    if (Platform.isAndroid) return 'MYA-$displayNameSuffix-Android-';
    throw UnsupportedError('Plateforme de mise à jour non prise en charge.');
  }

  static String get displayNameSuffix => switch (product) {
    MyaProduct.complete => 'Complete',
    MyaProduct.mobile => 'Mobile',
    MyaProduct.desktop => 'Desktop',
  };

  static void validatePlatform() {
    if (Platform.isAndroid && !supportsAndroid) {
      throw StateError('MYA Desktop ne peut pas être lancé sur Android.');
    }
    if (Platform.isWindows && !supportsWindows) {
      throw StateError('MYA Mobile ne peut pas être lancé sur Windows.');
    }
  }
}
