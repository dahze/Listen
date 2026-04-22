import 'package:equatable/equatable.dart';

class SpeechResult extends Equatable {
  final String transcript;
  final String speakerId;
  final bool isFinal;
  final String detectedLang;

  const SpeechResult({
    required this.transcript,
    required this.speakerId,
    required this.isFinal,
    required this.detectedLang,
  });

  @override
  List<Object> get props => [transcript, speakerId, isFinal, detectedLang];
}
