import 'package:equatable/equatable.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

final class HistoryLoadRequested extends HistoryEvent {
  final String userId;
  const HistoryLoadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

final class HistorySessionDeleted extends HistoryEvent {
  final String userId;
  final String sessionId;

  const HistorySessionDeleted({required this.userId, required this.sessionId});

  @override
  List<Object> get props => [userId, sessionId];
}
