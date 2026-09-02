import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/quick_add/models/quick_add_input.dart';

void main() {
  test('QuickAddInput valide un titre non vide', () {
    const input = QuickAddInput(title: '  Acheter du pain  ');
    expect(input.isValid, isTrue);
    expect(input.trimmedTitle, 'Acheter du pain');
    expect(input.category, TaskCategoryId.next);
  });

  test('QuickAddInput rejette un titre vide', () {
    const input = QuickAddInput(title: '   ');
    expect(input.isValid, isFalse);
  });
}
