import 'package:mya/domain/entities/task.dart';
/// Contrat de persistance des tâches — implémenté par Drift.
abstract class TaskRepository {
  Stream<List<Task>> watchTasks();

  Future<Task?> findById(String id);

  Future<void> addTask(Task task);

  Future<void> updateTask(Task task);

  /// Soft delete (status `deleted` + `deleted_at`).
  Future<void> deleteTask(String id);
}