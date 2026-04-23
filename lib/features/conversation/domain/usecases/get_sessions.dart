import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/conversation/domain/entities/session.dart';
import 'package:listen/features/conversation/domain/repositories/conversation_repository.dart';

class GetSessions implements UseCase<List<Session>, GetSessionsParams> {
  final ConversationRepository repository;
  const GetSessions(this.repository);

  @override
  Future<Either<Failure, List<Session>>> call(GetSessionsParams params) {
    return repository.getSessions(userId: params.userId);
  }
}

class GetSessionsParams extends Equatable {
  final String userId;
  const GetSessionsParams({required this.userId});

  @override
  List<Object> get props => [userId];
}
