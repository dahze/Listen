import 'package:equatable/equatable.dart';

sealed class PanelState extends Equatable {
  const PanelState();

  @override
  List<Object?> get props => [];
}

final class PanelIdle extends PanelState {
  const PanelIdle();
}

final class PanelListening extends PanelState {
  const PanelListening();
}

final class PanelTranscribing extends PanelState {
  final String partialText;
  const PanelTranscribing(this.partialText);

  @override
  List<Object?> get props => [partialText];
}

final class PanelPendingConfirmation extends PanelState {
  final String transcript;
  final String detectedLang;

  const PanelPendingConfirmation({
    required this.transcript,
    required this.detectedLang,
  });

  @override
  List<Object?> get props => [transcript, detectedLang];
}

final class PanelTranslating extends PanelState {
  const PanelTranslating();
}
