import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mya/domain/services/task_date_service.dart';

final taskDateServiceProvider =
    Provider<TaskDateService>((ref) => const TaskDateService());
