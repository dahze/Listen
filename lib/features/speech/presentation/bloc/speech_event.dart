import 'package:equatable/equatable.dart';

sealed class SpeechEvent extends Equatable {
  const SpeechEvent();

  @override
  List<Object> get props => [];
}

final class SpeechStartRequested extends SpeechEvent {
  final String speakerId;
  final String languageCode;

  const SpeechStartRequested({
    required this.speakerId,
    required this.languageCode,
  });

  @override
  List<Object> get props => [speakerId, languageCode];
}

final class SpeechStopRequested extends SpeechEvent {
  const SpeechStopRequested();
}

/// Fired internally by the datasource stream when a partial
/// transcript arrives — updates the panel text in real time.
final class SpeechPartialResult extends SpeechEvent {
  final String transcript;
  final String speakerId;

  const SpeechPartialResult({
    required this.transcript,
    required this.speakerId,
  });

  @override
  List<Object> get props => [transcript, speakerId];
}

/// Fired internally when isFinal=true — triggers confirmation UI.
final class SpeechFinalResult extends SpeechEvent {
  final String transcript;
  final String speakerId;
  final String detectedLang;

  const SpeechFinalResult({
    required this.transcript,
    required this.speakerId,
    required this.detectedLang,
  });

  @override
  List<Object> get props => [transcript, speakerId, detectedLang];
}

final class SpeechPermissionRequested extends SpeechEvent {
  const SpeechPermissionRequested();
}
