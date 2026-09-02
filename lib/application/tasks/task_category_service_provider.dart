import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/domain/services/task_category_service.dart';

/// Provider partagé pour le déplacement manuel de catégories.
final taskCategoryServiceProvider =
    Provider<TaskCategoryService>((ref) => const TaskCategoryService());
