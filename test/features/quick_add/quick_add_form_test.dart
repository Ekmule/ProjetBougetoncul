import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/quick_add/models/quick_add_input.dart';
import 'package:mya/features/quick_add/widgets/quick_add_form.dart';

void main() {
  testWidgets('QuickAddForm soumet avec Entrée', (tester) async {
    QuickAddInput? submitted;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickAddForm(
            onSubmit: (input) => submitted = input,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Test rapide');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(submitted?.trimmedTitle, 'Test rapide');
    expect(submitted?.category, TaskCategoryId.next);
  });

  testWidgets('QuickAddForm permet de choisir une catégorie', (tester) async {
    QuickAddInput? submitted;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickAddForm(
            onSubmit: (input) => submitted = input,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plus d\'options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BOUGE TON GROS CUL'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Urgent');
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    expect(submitted?.category, TaskCategoryId.mustDo);
  });
}
