/// Extensions date/heure pour la logique métier (catégories, rappels).
extension DateTimeMya on DateTime {
  /// Date locale sans composante horaire (minuit local).
  DateTime get dateOnly => DateTime(year, month, day);

  /// Vrai si la date correspond à aujourd'hui (calendrier local).
  bool isToday(DateTime reference) {
    return dateOnly == reference.dateOnly;
  }
}
