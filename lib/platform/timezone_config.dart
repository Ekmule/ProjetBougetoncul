import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Configure le fuseau horaire local pour la planification des rappels.
Future<void> configureLocalTimeZone() async {
  tz_data.initializeTimeZones();

  final offset = DateTime.now().timeZoneOffset;
  final hours = offset.inHours;

  if (hours == 0) {
    tz.setLocalLocation(tz.getLocation('UTC'));
    return;
  }

  // Les identifiants Etc/GMT ont un signe inversé par rapport à UTC.
  final sign = hours > 0 ? '-' : '+';
  tz.setLocalLocation(tz.getLocation('Etc/GMT$sign${hours.abs()}'));
}

/// Convertit une date locale en [TZDateTime] pour flutter_local_notifications.
tz.TZDateTime toLocalTzDateTime(DateTime dateTime) {
  return tz.TZDateTime(
    tz.local,
    dateTime.year,
    dateTime.month,
    dateTime.day,
    dateTime.hour,
    dateTime.minute,
    dateTime.second,
    dateTime.millisecond,
    dateTime.microsecond,
  );
}
