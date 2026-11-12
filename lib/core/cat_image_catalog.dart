/// Catalogue partagé des photos du chat affichées par MYA.
abstract final class CatImageCatalog {
  static const assetPaths = [
    'assets/super_alert/cat_01.jpg',
    'assets/super_alert/cat_02.jpg',
    'assets/super_alert/cat_03.jpg',
    'assets/super_alert/cat_04.jpg',
    'assets/super_alert/cat_05.jpg',
    'assets/super_alert/cat_06.jpg',
    'assets/super_alert/cat_07.jpg',
    'assets/super_alert/cat_08.jpg',
  ];

  /// Retourne une image stable pendant une journée, puis change le lendemain.
  static String forDate(DateTime date) {
    final day =
        DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final index =
        ((day % assetPaths.length) + assetPaths.length) % assetPaths.length;
    return assetPaths[index];
  }

  static String get today => forDate(DateTime.now());
}
