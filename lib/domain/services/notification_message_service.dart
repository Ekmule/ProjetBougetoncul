import 'package:mya/domain/entities/task.dart';

/// Textes des notifications MYA (style « normal » pour le MVP).
class NotificationMessageService {
  const NotificationMessageService();

  static const appTitle = 'MYA';

  /// Corps d'une notification de rappel — ex. « N'oublie pas : Faire les portraits. »
  String reminderBody(Task task) {
    return "N'oublie pas : ${task.title}.";
  }
}
