import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:listen/core/utils/language_detector.dart';
import 'package:listen/features/conversation/domain/entities/message.dart';
import 'package:listen/features/conversation/domain/usecases/add_message.dart';
import 'package:listen/features/conversation/domain/usecases/create_session.dart';
import 'package:listen/features/conversation/domain/usecases/end_session.dart';
import 'package:listen/features/speech/presentation/bloc/speech_bloc.dart';
import 'package:listen/features/speech/presentation/bloc/speech_event.dart';
import 'package:listen/features/speech/presentation/bloc/speech_state.dart';
import 'package:listen/features/translation/presentation/bloc/translation_bloc.dart';
import 'package:listen/features/translation/presentation/bloc/translation_event.dart';
import 'package:listen/features/translation/presentation/bloc/translation_state.dart';
import 'panel_state.dart';
import 'split_screen_event.dart';
import 'split_screen_state.dart';

class SplitScreenBloc extends Bloc<SplitScreenEvent, SplitScreenState> {
  final SpeechBloc _speechBloc;
  final TranslationBloc _translationBloc;
  final CreateSession _createSession;
  final AddMessage _addMessage;
  final EndSession _endSession;
  final String _userId;

  StreamSubscription<SpeechState>? _speechSub;
  StreamSubscription<TranslationState>? _translationSub;

  // Tracks which speaker is awaiting a translation result.
  String? _pendingSpeakerId;

  static const _uuid = Uuid();

  SplitScreenBloc({
    required SpeechBloc speechBloc,
    required TranslationBloc translationBloc,
    required CreateSession createSession,
    required AddMessage addMessage,
    required EndSession endSession,
    required String userId,
  }) : _speechBloc = speechBloc,
       _translationBloc = translationBloc,
       _createSession = createSession,
       _addMessage = addMessage,
       _endSession = endSession,
       _userId = userId,
       super(const SplitScreenInitial()) {
    on<SessionStartRequested>(_onSessionStartRequested);
    on<MicTapped>(_onMicTapped);
    on<TranscriptConfirmed>(_onTranscriptConfirmed);
    on<TranscriptDiscarded>(_onTranscriptDiscarded);
    on<RedoRequested>(_onRedoRequested);
    on<SessionEnded>(_onSessionEnded);
    on<SpeechStateUpdated>(_onSpeechStateUpdated);
    on<TranslationStateUpdated>(_onTranslationStateUpdated);

    // Subscribe to sibling BLoC streams and forward as internal events.
    _speechSub = _speechBloc.stream.listen((s) => add(SpeechStateUpdated(s)));
    _translationSub = _translationBloc.stream.listen(
      (s) => add(TranslationStateUpdated(s)),
    );
  }

  // ── Session lifecycle ────────────────────────────────────────────────────

  Future<void> _onSessionStartRequested(
    SessionStartRequested event,
    Emitter<SplitScreenState> emit,
  ) async {
    emit(const SplitScreenLoading());

    final nameA =
        event.speakerAName.trim().isEmpty
            ? 'Speaker A'
            : event.speakerAName.trim();
    final nameB =
        event.speakerBName.trim().isEmpty
            ? 'Speaker B'
            : event.speakerBName.trim();

    final result = await _createSession(
      CreateSessionParams(
        userId: _userId,
        speakerAName: nameA,
        speakerBName: nameB,
      ),
    );

    result.fold(
      (failure) => emit(SplitScreenError(failure.message)),
      (session) => emit(
        SplitScreenActive(
          sessionId: session.id,
          speakerAName: session.speakerAName,
          speakerBName: session.speakerBName,
          panelA: const PanelIdle(),
          panelB: const PanelIdle(),
          messages: const [],
        ),
      ),
    );
  }

  Future<void> _onSessionEnded(
    SessionEnded event,
    Emitter<SplitScreenState> emit,
  ) async {
    final current = state;
    if (current is! SplitScreenActive) return;

    _speechBloc.add(const SpeechStopRequested());

    await _endSession(
      EndSessionParams(userId: _userId, sessionId: current.sessionId),
    );

    emit(const SplitScreenEnded());
  }

  // ── Mic control ──────────────────────────────────────────────────────────

  void _onMicTapped(MicTapped event, Emitter<SplitScreenState> emit) {
    final current = state;
    if (current is! SplitScreenActive) return;

    // Guard — ignore tap if another speaker is active.
    if (current.activeSpeaker != null) return;

    // Panel A defaults to Urdu, Panel B defaults to English.
    final languageCode =
        event.speakerId == 'A'
            ? LanguageDetector.urdu
            : LanguageDetector.english;

    _speechBloc.add(
      SpeechStartRequested(
        speakerId: event.speakerId,
        languageCode: languageCode,
      ),
    );

    emit(
      event.speakerId == 'A'
          ? current.copyWith(
            activeSpeaker: () => 'A',
            panelA: const PanelListening(),
          )
          : current.copyWith(
            activeSpeaker: () => 'B',
            panelB: const PanelListening(),
          ),
    );
  }

  // ── Confirmation flow ────────────────────────────────────────────────────

  void _onTranscriptConfirmed(
    TranscriptConfirmed event,
    Emitter<SplitScreenState> emit,
  ) {
    final current = state;
    if (current is! SplitScreenActive) return;

    _pendingSpeakerId = event.speakerId;

    _translationBloc.add(
      TranslateRequested(
        text: event.transcript,
        sourceLang: event.detectedLang,
        targetLang: LanguageDetector.targetFor(event.detectedLang),
      ),
    );

    emit(
      event.speakerId == 'A'
          ? current.copyWith(panelA: const PanelTranslating())
          : current.copyWith(panelB: const PanelTranslating()),
    );
  }

  void _onTranscriptDiscarded(
    TranscriptDiscarded event,
    Emitter<SplitScreenState> emit,
  ) {
    final current = state;
    if (current is! SplitScreenActive) return;

    _speechBloc.add(const SpeechStopRequested());

    emit(
      event.speakerId == 'A'
          ? current.copyWith(
            activeSpeaker: () => null,
            panelA: const PanelIdle(),
          )
          : current.copyWith(
            activeSpeaker: () => null,
            panelB: const PanelIdle(),
          ),
    );
  }

  void _onRedoRequested(RedoRequested event, Emitter<SplitScreenState> emit) {
    final current = state;
    if (current is! SplitScreenActive) return;

    final languageCode =
        event.speakerId == 'A'
            ? LanguageDetector.urdu
            : LanguageDetector.english;

    // Auto-restart mic for same speaker.
    _speechBloc.add(
      SpeechStartRequested(
        speakerId: event.speakerId,
        languageCode: languageCode,
      ),
    );

    emit(
      event.speakerId == 'A'
          ? current.copyWith(panelA: const PanelListening())
          : current.copyWith(panelB: const PanelListening()),
    );
  }

  // ── Internal stream reactions ────────────────────────────────────────────

  void _onSpeechStateUpdated(
    SpeechStateUpdated event,
    Emitter<SplitScreenState> emit,
  ) {
    final current = state;
    if (current is! SplitScreenActive) return;

    final s = event.speechState;

    if (s is SpeechTranscribing) {
      emit(
        s.speakerId == 'A'
            ? current.copyWith(panelA: PanelTranscribing(s.partialTranscript))
            : current.copyWith(panelB: PanelTranscribing(s.partialTranscript)),
      );
    } else if (s is SpeechDone) {
      emit(
        s.result.speakerId == 'A'
            ? current.copyWith(
              panelA: PanelPendingConfirmation(
                transcript: s.result.transcript,
                detectedLang: s.result.detectedLang,
              ),
            )
            : current.copyWith(
              panelB: PanelPendingConfirmation(
                transcript: s.result.transcript,
                detectedLang: s.result.detectedLang,
              ),
            ),
      );
    } else if (s is SpeechError) {
      emit(SplitScreenError(s.message));
    }
  }

  Future<void> _onTranslationStateUpdated(
    TranslationStateUpdated event,
    Emitter<SplitScreenState> emit,
  ) async {
    final current = state;
    if (current is! SplitScreenActive) return;
    if (_pendingSpeakerId == null) return;

    final s = event.translationState;

    if (s is TranslationSuccess) {
      final speakerId = _pendingSpeakerId!;
      _pendingSpeakerId = null;

      final speakerName =
          speakerId == 'A' ? current.speakerAName : current.speakerBName;

      final message = Message(
        id: _uuid.v4(),
        speakerId: speakerId,
        speakerName: speakerName,
        originalText: s.translation.originalText,
        translatedText: s.translation.translatedText,
        sourceLang: s.translation.sourceLang,
        targetLang: s.translation.targetLang,
        timestamp: DateTime.now(),
      );

      // Fire-and-forget — Firestore write failure doesn't block the UI.
      _addMessage(
        AddMessageParams(
          userId: _userId,
          sessionId: current.sessionId,
          message: message,
        ),
      );

      final updatedMessages = [...current.messages, message];

      emit(
        speakerId == 'A'
            ? current.copyWith(
              activeSpeaker: () => null,
              panelA: const PanelIdle(),
              messages: updatedMessages,
            )
            : current.copyWith(
              activeSpeaker: () => null,
              panelB: const PanelIdle(),
              messages: updatedMessages,
            ),
      );
    } else if (s is TranslationError) {
      _pendingSpeakerId = null;
      emit(SplitScreenError(s.message));
    }
  }

  @override
  Future<void> close() async {
    await _speechSub?.cancel();
    await _translationSub?.cancel();
    return super.close();
  }
}
