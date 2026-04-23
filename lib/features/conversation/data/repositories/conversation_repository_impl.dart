import 'package:dartz/dartz.dart';
import 'package:listen/core/error/exceptions.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/features/conversation/data/datasources/conversation_firebase_datasource.dart';
import 'package:listen/features/conversation/data/models/message_model.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';
import 'package:listen/features/conversation/domain/entities/session.dart';
import 'package:listen/features/conversation/domain/repositories/conversation_repository.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ConversationFirebaseDatasource datasource;
  const ConversationRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, Session>> createSession({
    required String userId,
    required String speakerAName,
    required String speakerBName,
  }) async {
    try {
      final model = await datasource.createSession(
        userId: userId,
        speakerAName: speakerAName,
        speakerBName: speakerBName,
      );
      return Right(model);
    } on ConversationException catch (e) {
      return Left(ConversationFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addMessage({
    required String userId,
    required String sessionId,
    required Message message,
  }) async {
    try {
      await datasource.addMessage(
        userId: userId,
        sessionId: sessionId,
        message: MessageModel.fromEntity(message),
      );
      return const Right(null);
    } on ConversationException catch (e) {
      return Left(ConversationFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Session>>> getSessions({
    required String userId,
  }) async {
    try {
      final models = await datasource.getSessions(userId: userId);
      return Right(models);
    } on ConversationException catch (e) {
      return Left(ConversationFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      await datasource.deleteSession(userId: userId, sessionId: sessionId);
      return const Right(null);
    } on ConversationException catch (e) {
      return Left(ConversationFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> endSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      await datasource.endSession(userId: userId, sessionId: sessionId);
      return const Right(null);
    } on ConversationException catch (e) {
      return Left(ConversationFailure(e.message));
    }
  }
}
