/// Conversion des dates entre le domaine et SQLite (voir docs/database.md §8.2).
abstract final class DateCodec {
  /// Date seule au format `YYYY-MM-DD` (sans fuseau horaire).
  static String? toPlannedDateString(DateTime? date) {
    if (date == null) return null;
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }

  static DateTime? fromPlannedDateString(String? value) {
    if (value == null || value.isEmpty) return null;

    final parts = value.split('-');
    if (parts.length != 3) {
      throw FormatException('Date planifiée invalide: $value');
    }

    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Timestamp UTC en millisecondes depuis epoch.
  static int toUtcMillis(DateTime dateTime) => dateTime.toUtc().millisecondsSinceEpoch;

  static DateTime fromUtcMillis(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
  }
}
