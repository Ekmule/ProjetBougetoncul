import 'package:mya/domain/entities/task.dart';

/// Données saisies via la création rapide (D5).
class QuickAddInput {
  const QuickAddInput({
    required this.title,
    this.category = TaskCategoryId.next,
  });

  final String title;
  final TaskCategoryId category;

  String get trimmedTitle => title.trim();

  bool get isValid => trimmedTitle.isNotEmpty;
}
