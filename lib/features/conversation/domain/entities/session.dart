import 'package:equatable/equatable.dart';
import 'message.dart';

class Session extends Equatable {
  final String id;
  final String speakerAName;
  final String speakerBName;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime? endedAt;

  const Session({
    required this.id,
    required this.speakerAName,
    required this.speakerBName,
    required this.messages,
    required this.createdAt,
    this.endedAt,
  });

  int get messageCount => messages.length;

  Session copyWith({List<Message>? messages, DateTime? endedAt}) {
    return Session(
      id: id,
      speakerAName: speakerAName,
      speakerBName: speakerBName,
      messages: messages ?? this.messages,
      createdAt: createdAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    speakerAName,
    speakerBName,
    messages,
    createdAt,
    endedAt,
  ];
}
