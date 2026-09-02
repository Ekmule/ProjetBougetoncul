import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/domain/services/notification_message_service.dart';

void main() {
  const service = NotificationMessageService();

  test('reminderBody utilise le style normal', () {
    final task = Task.createNew(id: 't1', title: 'Faire les portraits');

    expect(
      service.reminderBody(task),
      "N'oublie pas : Faire les portraits.",
    );
  });
}
