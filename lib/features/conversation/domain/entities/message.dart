import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String speakerId;
  final String speakerName;
  final String originalText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.speakerId,
    required this.speakerName,
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    required this.timestamp,
  });

  @override
  List<Object> get props => [
    id,
    speakerId,
    speakerName,
    originalText,
    translatedText,
    sourceLang,
    targetLang,
    timestamp,
  ];
}
