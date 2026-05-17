import 'package:equatable/equatable.dart';
import 'package:listen/features/speech/presentation/bloc/speech_state.dart';
import 'package:listen/features/translation/presentation/bloc/translation_state.dart';

sealed class SplitScreenEvent extends Equatable {
  const SplitScreenEvent();

  @override
  List<Object?> get props => [];
}

final class SessionStartRequested extends SplitScreenEvent {
  final String speakerAName;
  final String speakerBName;

  const SessionStartRequested({
    required this.speakerAName,
    required this.speakerBName,
  });

  @override
  List<Object?> get props => [speakerAName, speakerBName];
}

final class MicTapped extends SplitScreenEvent {
  final String speakerId;
  const MicTapped(this.speakerId);

  @override
  List<Object?> get props => [speakerId];
}

final class TranscriptConfirmed extends SplitScreenEvent {
  final String speakerId;
  final String transcript;
  final String detectedLang;

  const TranscriptConfirmed({
    required this.speakerId,
    required this.transcript,
    required this.detectedLang,
  });

  @override
  List<Object?> get props => [speakerId, transcript, detectedLang];
}

final class TranscriptDiscarded extends SplitScreenEvent {
  final String speakerId;
  const TranscriptDiscarded(this.speakerId);

  @override
  List<Object?> get props => [speakerId];
}

final class RedoRequested extends SplitScreenEvent {
  final String speakerId;
  const RedoRequested(this.speakerId);

  @override
  List<Object?> get props => [speakerId];
}

final class SessionEnded extends SplitScreenEvent {
  const SessionEnded();
}

// ── Internal events ────────────────────────────────────────────────────────
// Fired by SplitScreenBloc when it reacts to SpeechBloc/TranslationBloc
// stream changes. Widgets never fire these.

final class SpeechStateUpdated extends SplitScreenEvent {
  final SpeechState speechState;
  const SpeechStateUpdated(this.speechState);

  @override
  List<Object?> get props => [speechState];
}

final class TranslationStateUpdated extends SplitScreenEvent {
  final TranslationState translationState;
  const TranslationStateUpdated(this.translationState);

  @override
  List<Object?> get props => [translationState];
}
