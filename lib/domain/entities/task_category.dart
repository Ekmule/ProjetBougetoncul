/// Identifiants stables des catégories MYA.
///
/// Les libellés affichés (ex: "BOUGE TON GROS CUL") peuvent changer,
/// mais ces identifiants ne changent jamais.
enum TaskCategoryId {
  mustDo,
  today,
  next,
  someday,
}

/// Libellés et couleurs par défaut (ADR-019).
extension TaskCategoryIdLabels on TaskCategoryId {
  String get defaultLabel => switch (this) {
        TaskCategoryId.mustDo => 'BOUGE TON GROS CUL',
        TaskCategoryId.today => 'AUJOURD\'HUI',
        TaskCategoryId.next => 'ENSUITE',
        TaskCategoryId.someday => 'À FAIRE SI J\'AI LE TEMPS',
      };

  int get colorValue => switch (this) {
        TaskCategoryId.mustDo => 0xFFE53935,
        TaskCategoryId.today => 0xFFFB8C00,
        TaskCategoryId.next => 0xFFFDD835,
        TaskCategoryId.someday => 0xFF9E9E9E,
      };
}

/// Conversion vers/depuis la valeur stockée en base (`must_do`, `today`, …).
extension TaskCategoryIdDb on TaskCategoryId {
  String get dbValue => switch (this) {
        TaskCategoryId.mustDo => 'must_do',
        TaskCategoryId.today => 'today',
        TaskCategoryId.next => 'next',
        TaskCategoryId.someday => 'someday',
      };

  static TaskCategoryId fromDb(String value) {
    return TaskCategoryId.values.firstWhere(
      (category) => category.dbValue == value,
      orElse: () => throw ArgumentError('Catégorie inconnue: $value'),
    );
  }
}
