import 'package:equatable/equatable.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';
import 'panel_state.dart';

sealed class SplitScreenState extends Equatable {
  const SplitScreenState();

  @override
  List<Object?> get props => [];
}

final class SplitScreenInitial extends SplitScreenState {
  const SplitScreenInitial();
}

final class SplitScreenLoading extends SplitScreenState {
  const SplitScreenLoading();
}

final class SplitScreenActive extends SplitScreenState {
  final String sessionId;
  final String speakerAName;
  final String speakerBName;
  final String? activeSpeaker;
  final PanelState panelA;
  final PanelState panelB;
  final List<Message> messages;

  const SplitScreenActive({
    required this.sessionId,
    required this.speakerAName,
    required this.speakerBName,
    this.activeSpeaker,
    required this.panelA,
    required this.panelB,
    required this.messages,
  });

  SplitScreenActive copyWith({
    String? Function()? activeSpeaker,
    PanelState? panelA,
    PanelState? panelB,
    List<Message>? messages,
  }) {
    return SplitScreenActive(
      sessionId: sessionId,
      speakerAName: speakerAName,
      speakerBName: speakerBName,
      activeSpeaker:
          activeSpeaker != null ? activeSpeaker() : this.activeSpeaker,
      panelA: panelA ?? this.panelA,
      panelB: panelB ?? this.panelB,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [
    sessionId,
    speakerAName,
    speakerBName,
    activeSpeaker,
    panelA,
    panelB,
    messages,
  ];
}

final class SplitScreenEnded extends SplitScreenState {
  const SplitScreenEnded();
}

final class SplitScreenError extends SplitScreenState {
  final String message;
  const SplitScreenError(this.message);

  @override
  List<Object?> get props => [message];
}
