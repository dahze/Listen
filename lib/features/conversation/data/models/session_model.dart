import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';
import 'package:listen/features/conversation/domain/entities/session.dart';

class SessionModel extends Session {
  const SessionModel({
    required super.id,
    required super.speakerAName,
    required super.speakerBName,
    required super.messages,
    required super.createdAt,
    super.endedAt,
  });

  factory SessionModel.fromFirestore(
    DocumentSnapshot doc,
    List<Message> messages,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      speakerAName: data['speakerAName'] as String,
      speakerBName: data['speakerBName'] as String,
      messages: messages,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      endedAt:
          data['endedAt'] != null
              ? (data['endedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'speakerAName': speakerAName,
      'speakerBName': speakerBName,
      'createdAt': Timestamp.fromDate(createdAt),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'messageCount': messages.length,
    };
  }
}
