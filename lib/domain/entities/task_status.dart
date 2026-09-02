/// Statut métier d'une tâche — indépendant de la catégorie d'affichage.
enum TaskStatus {
  active,
  completed,
  deleted,
}

/// Conversion vers/depuis la valeur stockée en base (`active`, `completed`, `deleted`).
extension TaskStatusDb on TaskStatus {
  String get dbValue => name;

  static TaskStatus fromDb(String value) {
    return TaskStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => throw ArgumentError('Statut de tâche inconnu: $value'),
    );
  }
}
