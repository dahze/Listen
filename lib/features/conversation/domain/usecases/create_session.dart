import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/conversation/domain/entities/session.dart';
import 'package:listen/features/conversation/domain/repositories/conversation_repository.dart';

class CreateSession implements UseCase<Session, CreateSessionParams> {
  final ConversationRepository repository;
  const CreateSession(this.repository);

  @override
  Future<Either<Failure, Session>> call(CreateSessionParams params) {
    return repository.createSession(
      userId: params.userId,
      speakerAName: params.speakerAName,
      speakerBName: params.speakerBName,
    );
  }
}

class CreateSessionParams extends Equatable {
  final String userId;
  final String speakerAName;
  final String speakerBName;

  const CreateSessionParams({
    required this.userId,
    required this.speakerAName,
    required this.speakerBName,
  });

  @override
  List<Object> get props => [userId, speakerAName, speakerBName];
}
