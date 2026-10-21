import 'package:mya/l10n/app_locale_code.dart';



/// Formatage des dates pour l'affichage MYA (sans dépendance intl).

abstract final class DateDisplay {

  static const _monthsFr = <String>[

    'jan.',

    'fév.',

    'mars',

    'avr.',

    'mai',

    'juin',

    'juil.',

    'août',

    'sep.',

    'oct.',

    'nov.',

    'déc.',

  ];



  static const _monthsEn = <String>[

    'Jan',

    'Feb',

    'Mar',

    'Apr',

    'May',

    'Jun',

    'Jul',

    'Aug',

    'Sep',

    'Oct',

    'Nov',

    'Dec',

  ];



  /// Ex. « 25 août » / « 25 Aug » pour une date planifiée.

  static String plannedDate(

    DateTime date, {

    AppLocaleCode locale = AppLocaleCode.fr,

  }) {

    final months = locale == AppLocaleCode.fr ? _monthsFr : _monthsEn;

    return '${date.day} ${months[date.month - 1]}';

  }



  /// Ex. « 25 août à 14h00 » / « 25 Aug at 14:00 » pour un rappel.

  static String reminderDateTime(

    DateTime dateTime, {

    AppLocaleCode locale = AppLocaleCode.fr,

  }) {

    final minutes = dateTime.minute.toString().padLeft(2, '0');

    if (locale == AppLocaleCode.fr) {

      return '${plannedDate(dateTime, locale: locale)} à ${dateTime.hour}h$minutes';

    }

    return '${plannedDate(dateTime, locale: locale)} at ${dateTime.hour}:$minutes';

  }

}


