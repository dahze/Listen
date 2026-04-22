import 'package:equatable/equatable.dart';
import 'package:listen/features/speech/domain/entities/speech_result.dart';

sealed class SpeechState extends Equatable {
  const SpeechState();

  @override
  List<Object?> get props => [];
}

final class SpeechInitial extends SpeechState {
  const SpeechInitial();
}

final class SpeechPermissionGranted extends SpeechState {
  const SpeechPermissionGranted();
}

final class SpeechPermissionDenied extends SpeechState {
  const SpeechPermissionDenied();
}

final class SpeechListening extends SpeechState {
  final String speakerId;
  const SpeechListening(this.speakerId);

  @override
  List<Object?> get props => [speakerId];
}

final class SpeechTranscribing extends SpeechState {
  final String speakerId;
  final String partialTranscript;

  const SpeechTranscribing({
    required this.speakerId,
    required this.partialTranscript,
  });

  @override
  List<Object?> get props => [speakerId, partialTranscript];
}

final class SpeechDone extends SpeechState {
  final SpeechResult result;
  const SpeechDone(this.result);

  @override
  List<Object?> get props => [result];
}

final class SpeechError extends SpeechState {
  final String message;
  const SpeechError(this.message);

  @override
  List<Object?> get props => [message];
}
