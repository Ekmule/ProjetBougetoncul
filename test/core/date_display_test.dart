import 'package:flutter_test/flutter_test.dart';

import 'package:mya/core/utils/date_display.dart';

import 'package:mya/l10n/app_locale_code.dart';



void main() {

  test('reminderDateTime formate date et heure (fr)', () {

    final formatted = DateDisplay.reminderDateTime(

      DateTime(2026, 8, 25, 14),

      locale: AppLocaleCode.fr,

    );



    expect(formatted, '25 août à 14h00');

  });



  test('reminderDateTime formate date et heure (en)', () {

    final formatted = DateDisplay.reminderDateTime(

      DateTime(2026, 8, 25, 14),

      locale: AppLocaleCode.en,

    );



    expect(formatted, '25 Aug at 14:00');

  });

}


