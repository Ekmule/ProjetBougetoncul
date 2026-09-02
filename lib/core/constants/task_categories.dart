import 'package:mya/domain/entities/task.dart';

/// Ordre d'affichage des sections (ADR-017).
abstract final class TaskCategoryDisplay {
  static const displayOrder = <TaskCategoryId>[
    TaskCategoryId.mustDo,
    TaskCategoryId.today,
    TaskCategoryId.next,
    TaskCategoryId.someday,
  ];
}
