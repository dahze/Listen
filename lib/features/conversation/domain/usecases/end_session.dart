import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/conversation/domain/repositories/conversation_repository.dart';

class EndSession implements UseCase<void, EndSessionParams> {
  final ConversationRepository repository;
  const EndSession(this.repository);

  @override
  Future<Either<Failure, void>> call(EndSessionParams params) {
    return repository.endSession(
      userId: params.userId,
      sessionId: params.sessionId,
    );
  }
}

class EndSessionParams extends Equatable {
  final String userId;
  final String sessionId;

  const EndSessionParams({required this.userId, required this.sessionId});

  @override
  List<Object> get props => [userId, sessionId];
}
