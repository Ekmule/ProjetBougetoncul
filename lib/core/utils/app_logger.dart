import 'package:logger/logger.dart';

/// Logger partagé — niveau debug en développement, info en production.
final appLogger = Logger(
  printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5),
  level: Level.debug,
);
