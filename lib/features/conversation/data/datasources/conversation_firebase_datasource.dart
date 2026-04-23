import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listen/core/error/exceptions.dart';
import 'package:listen/features/conversation/data/models/message_model.dart';
import 'package:listen/features/conversation/data/models/session_model.dart';

abstract class ConversationFirebaseDatasource {
  Future<SessionModel> createSession({
    required String userId,
    required String speakerAName,
    required String speakerBName,
  });

  Future<void> addMessage({
    required String userId,
    required String sessionId,
    required MessageModel message,
  });

  Future<List<SessionModel>> getSessions({required String userId});

  Future<void> deleteSession({
    required String userId,
    required String sessionId,
  });

  Future<void> endSession({required String userId, required String sessionId});
}

class ConversationFirebaseDatasourceImpl
    implements ConversationFirebaseDatasource {
  final FirebaseFirestore _db;
  const ConversationFirebaseDatasourceImpl(this._db);

  CollectionReference _sessions(String userId) =>
      _db.collection('users').doc(userId).collection('sessions');

  CollectionReference _messages(String userId, String sessionId) =>
      _sessions(userId).doc(sessionId).collection('messages');

  @override
  Future<SessionModel> createSession({
    required String userId,
    required String speakerAName,
    required String speakerBName,
  }) async {
    try {
      final now = DateTime.now();
      final model = SessionModel(
        id: '',
        speakerAName: speakerAName,
        speakerBName: speakerBName,
        messages: const [],
        createdAt: now,
      );
      final ref = await _sessions(userId).add(model.toFirestore());
      return SessionModel(
        id: ref.id,
        speakerAName: speakerAName,
        speakerBName: speakerBName,
        messages: const [],
        createdAt: now,
      );
    } catch (e) {
      throw ConversationException('Failed to create session: $e');
    }
  }

  @override
  Future<void> addMessage({
    required String userId,
    required String sessionId,
    required MessageModel message,
  }) async {
    try {
      await _messages(userId, sessionId).add(message.toFirestore());
    } catch (e) {
      throw ConversationException('Failed to save message: $e');
    }
  }

  @override
  Future<List<SessionModel>> getSessions({required String userId}) async {
    try {
      final sessionSnap =
          await _sessions(userId).orderBy('createdAt', descending: true).get();

      final sessions = <SessionModel>[];

      for (final doc in sessionSnap.docs) {
        final messagesSnap =
            await _messages(userId, doc.id).orderBy('timestamp').get();

        final messages =
            messagesSnap.docs
                .map((m) => MessageModel.fromFirestore(m))
                .toList();

        sessions.add(SessionModel.fromFirestore(doc, messages));
      }

      return sessions;
    } catch (e) {
      throw ConversationException('Failed to fetch sessions: $e');
    }
  }

  @override
  Future<void> deleteSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      // Delete all messages first — Firestore does not cascade deletes.
      final messagesSnap = await _messages(userId, sessionId).get();
      final batch = _db.batch();
      for (final doc in messagesSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_sessions(userId).doc(sessionId));
      await batch.commit();
    } catch (e) {
      throw ConversationException('Failed to delete session: $e');
    }
  }

  @override
  Future<void> endSession({
    required String userId,
    required String sessionId,
  }) async {
    try {
      await _sessions(
        userId,
      ).doc(sessionId).update({'endedAt': Timestamp.fromDate(DateTime.now())});
    } catch (e) {
      throw ConversationException('Failed to end session: $e');
    }
  }
}
