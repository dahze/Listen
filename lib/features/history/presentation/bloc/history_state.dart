import 'package:equatable/equatable.dart';
import 'package:listen/features/conversation/domain/entities/session.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

final class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

final class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

final class HistoryLoaded extends HistoryState {
  final List<Session> sessions;
  const HistoryLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

final class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
