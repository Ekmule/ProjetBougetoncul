import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mya/domain/entities/task.dart';
import 'package:mya/features/quick_add/models/quick_add_input.dart';
import 'package:mya/features/quick_add/widgets/quick_add_form.dart';
import '../../test_app_shell.dart';
import 'package:mya/l10n/app_locale_code.dart';
import 'package:mya/l10n/mya_localizations.dart';

void main() {
  testWidgets('QuickAddForm soumet avec Entrée', (tester) async {
    QuickAddInput? submitted;

    await tester.pumpWidget(
      testMaterialApp(
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
    final l10n = MyaLocalizations.lookup(AppLocaleCode.fr);

    await tester.pumpWidget(
      testMaterialApp(
        home: Scaffold(
          body: QuickAddForm(
            onSubmit: (input) => submitted = input,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.quickAddShowOptions));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.categoryMustDo));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Urgent');
    await tester.tap(find.text(l10n.add));
    await tester.pumpAndSettle();

    expect(submitted?.category, TaskCategoryId.mustDo);
  });
}
