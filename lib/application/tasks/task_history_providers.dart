import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/domain/entities/history_settings.dart';
import 'package:mya/domain/services/task_history_service.dart';

final taskHistoryServiceProvider =
    Provider<TaskHistoryService>((ref) => const TaskHistoryService());

/// Durée de conservation de l'historique (jours). Paramètres UI en D12.
final historyRetentionDaysProvider = Provider<int>(
  (ref) => HistorySettings.defaultRetentionDays,
);
