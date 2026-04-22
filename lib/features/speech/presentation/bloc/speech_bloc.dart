import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/speech/domain/usecases/listen_speech.dart';
import 'package:listen/features/speech/domain/usecases/request_permission.dart';
import 'package:listen/features/speech/domain/usecases/stop_listening.dart';
import 'package:listen/features/speech/domain/entities/speech_result.dart';
import 'speech_event.dart';
import 'speech_state.dart';

class SpeechBloc extends Bloc<SpeechEvent, SpeechState> {
  final ListenSpeech _listenSpeech;
  final StopListening _stopListening;
  final RequestPermission _requestPermission;

  StreamSubscription? _speechSubscription;

  SpeechBloc({
    required ListenSpeech listenSpeech,
    required StopListening stopListening,
    required RequestPermission requestPermission,
  }) : _listenSpeech = listenSpeech,
       _stopListening = stopListening,
       _requestPermission = requestPermission,
       super(const SpeechInitial()) {
    on<SpeechPermissionRequested>(_onPermissionRequested);
    on<SpeechStartRequested>(_onStartRequested);
    on<SpeechStopRequested>(_onStopRequested);
    on<SpeechPartialResult>(_onPartialResult);
    on<SpeechFinalResult>(_onFinalResult);
  }

  Future<void> _onPermissionRequested(
    SpeechPermissionRequested event,
    Emitter<SpeechState> emit,
  ) async {
    final result = await _requestPermission(NoParams());
    result.fold(
      (failure) => emit(SpeechError(failure.message)),
      (granted) =>
          granted
              ? emit(const SpeechPermissionGranted())
              : emit(const SpeechPermissionDenied()),
    );
  }

  Future<void> _onStartRequested(
    SpeechStartRequested event,
    Emitter<SpeechState> emit,
  ) async {
    await _speechSubscription?.cancel();
    emit(SpeechListening(event.speakerId));

    _speechSubscription = _listenSpeech(
      ListenSpeechParams(
        speakerId: event.speakerId,
        languageCode: event.languageCode,
      ),
    ).listen(
      (either) => either.fold(
        (failure) => add(
          SpeechFinalResult(
            transcript: '',
            speakerId: event.speakerId,
            detectedLang: event.languageCode,
          ),
        ),
        (result) {
          if (result.isFinal) {
            add(
              SpeechFinalResult(
                transcript: result.transcript,
                speakerId: result.speakerId,
                detectedLang: result.detectedLang,
              ),
            );
          } else {
            add(
              SpeechPartialResult(
                transcript: result.transcript,
                speakerId: result.speakerId,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _onStopRequested(
    SpeechStopRequested event,
    Emitter<SpeechState> emit,
  ) async {
    await _speechSubscription?.cancel();
    _speechSubscription = null;
    final result = await _stopListening(NoParams());
    result.fold(
      (failure) => emit(SpeechError(failure.message)),
      (_) => emit(const SpeechInitial()),
    );
  }

  void _onPartialResult(SpeechPartialResult event, Emitter<SpeechState> emit) {
    emit(
      SpeechTranscribing(
        speakerId: event.speakerId,
        partialTranscript: event.transcript,
      ),
    );
  }

  void _onFinalResult(SpeechFinalResult event, Emitter<SpeechState> emit) {
    emit(
      SpeechDone(
        SpeechResult(
          transcript: event.transcript,
          speakerId: event.speakerId,
          isFinal: true,
          detectedLang: event.detectedLang,
        ),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _speechSubscription?.cancel();
    return super.close();
  }
}
