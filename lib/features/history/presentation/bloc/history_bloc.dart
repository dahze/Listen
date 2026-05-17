import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listen/features/conversation/domain/usecases/delete_session.dart';
import 'package:listen/features/conversation/domain/usecases/get_sessions.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetSessions _getSessions;
  final DeleteSession _deleteSession;

  HistoryBloc({
    required GetSessions getSessions,
    required DeleteSession deleteSession,
  }) : _getSessions = getSessions,
       _deleteSession = deleteSession,
       super(const HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistorySessionDeleted>(_onSessionDeleted);
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    final result = await _getSessions(GetSessionsParams(userId: event.userId));
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (sessions) => emit(HistoryLoaded(sessions)),
    );
  }

  Future<void> _onSessionDeleted(
    HistorySessionDeleted event,
    Emitter<HistoryState> emit,
  ) async {
    // Optimistically remove from current list while Firestore deletes.
    final current = state;
    if (current is HistoryLoaded) {
      final updated =
          current.sessions.where((s) => s.id != event.sessionId).toList();
      emit(HistoryLoaded(updated));
    }

    final result = await _deleteSession(
      DeleteSessionParams(userId: event.userId, sessionId: event.sessionId),
    );

    result.fold(
      (failure) {
        // Revert on failure — reload the full list.
        add(HistoryLoadRequested(event.userId));
      },
      (_) {
        // Already updated optimistically — nothing more to do.
      },
    );
  }
}
