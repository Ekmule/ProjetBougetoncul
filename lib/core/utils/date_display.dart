/// Formatage des dates pour l'affichage MYA (sans dépendance intl).
abstract final class DateDisplay {
  static const _months = <String>[
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

  /// Ex. « 25 août » pour une date planifiée.
  static String plannedDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]}';
  }

  /// Ex. « 25 août à 14h00 » pour un rappel.
  static String reminderDateTime(DateTime dateTime) {
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '${plannedDate(dateTime)} à ${dateTime.hour}h$minutes';
  }
}
