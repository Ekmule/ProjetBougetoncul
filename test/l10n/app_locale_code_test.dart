import 'package:flutter_test/flutter_test.dart';
import 'package:mya/l10n/app_locale_code.dart';

void main() {
  test('parse locale depuis installateur', () {
    expect(AppLocaleCode.parse('fr'), AppLocaleCode.fr);
    expect(AppLocaleCode.parse('en'), AppLocaleCode.en);
  });

  test('defaut sans cle historique', () {
    expect(
      AppLocaleCode.defaultWhenUnset(android: false),
      AppLocaleCode.fr,
    );
    expect(
      AppLocaleCode.defaultWhenUnset(android: true),
      AppLocaleCode.en,
    );
  });
}
