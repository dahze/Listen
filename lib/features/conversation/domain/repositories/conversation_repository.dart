import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';
import 'package:listen/features/conversation/domain/entities/session.dart';

abstract class ConversationRepository {
  Future<Either<Failure, Session>> createSession({
    required String userId,
    required String speakerAName,
    required String speakerBName,
  });

  Future<Either<Failure, void>> addMessage({
    required String userId,
    required String sessionId,
    required Message message,
  });

  Future<Either<Failure, List<Session>>> getSessions({required String userId});

  Future<Either<Failure, void>> deleteSession({
    required String userId,
    required String sessionId,
  });

  Future<Either<Failure, void>> endSession({
    required String userId,
    required String sessionId,
  });
}
