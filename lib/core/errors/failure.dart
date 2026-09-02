import 'package:equatable/equatable.dart';

/// Représentation d'une erreur affichable ou loggable côté UI.
class Failure extends Equatable {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}
