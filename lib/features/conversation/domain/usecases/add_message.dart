import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';
import 'package:listen/features/conversation/domain/repositories/conversation_repository.dart';

class AddMessage implements UseCase<void, AddMessageParams> {
  final ConversationRepository repository;
  const AddMessage(this.repository);

  @override
  Future<Either<Failure, void>> call(AddMessageParams params) {
    return repository.addMessage(
      userId: params.userId,
      sessionId: params.sessionId,
      message: params.message,
    );
  }
}

class AddMessageParams extends Equatable {
  final String userId;
  final String sessionId;
  final Message message;

  const AddMessageParams({
    required this.userId,
    required this.sessionId,
    required this.message,
  });

  @override
  List<Object> get props => [userId, sessionId, message];
}
