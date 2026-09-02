/// Exception métier ou technique remontée depuis les couches data/application.
class MyaException implements Exception {
  const MyaException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'MyaException: $message';
}
