import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.speakerId,
    required super.speakerName,
    required super.originalText,
    required super.translatedText,
    required super.sourceLang,
    required super.targetLang,
    required super.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      speakerId: data['speakerId'] as String,
      speakerName: data['speakerName'] as String,
      originalText: data['originalText'] as String,
      translatedText: data['translatedText'] as String,
      sourceLang: data['sourceLang'] as String,
      targetLang: data['targetLang'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'speakerId': speakerId,
      'speakerName': speakerName,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLang': sourceLang,
      'targetLang': targetLang,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      speakerId: message.speakerId,
      speakerName: message.speakerName,
      originalText: message.originalText,
      translatedText: message.translatedText,
      sourceLang: message.sourceLang,
      targetLang: message.targetLang,
      timestamp: message.timestamp,
    );
  }
}
