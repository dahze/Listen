import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class TranslationFailure extends Failure {
  const TranslationFailure(super.message);
}

class SpeechFailure extends Failure {
  const SpeechFailure(super.message);
}

class ConversationFailure extends Failure {
  const ConversationFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
