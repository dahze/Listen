import 'package:listen/core/error/exceptions.dart';
import 'package:listen/core/utils/language_detector.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';

abstract class SpeechDatasource {
  Stream<SpeechResultRaw> startListening({
    required String speakerId,
    required String languageCode,
  });

  Future<void> stopListening();
  Future<bool> requestPermission();
}

class SpeechResultRaw {
  final String transcript;
  final String speakerId;
  final bool isFinal;

  const SpeechResultRaw({
    required this.transcript,
    required this.speakerId,
    required this.isFinal,
  });
}

class SpeechDatasourceImpl implements SpeechDatasource {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialised = false;

  @override
  Future<bool> requestPermission() async {
    try {
      _isInitialised = await _speech.initialize(
        onError: (error) => throw SpeechException(error.errorMsg),
      );
      return _isInitialised;
    } catch (e) {
      throw SpeechException('Microphone permission denied: $e');
    }
  }

  @override
  Stream<SpeechResultRaw> startListening({
    required String speakerId,
    required String languageCode,
  }) {
    if (!_isInitialised) {
      throw const SpeechException(
        'Speech not initialised — call requestPermission first',
      );
    }

    final controller = StreamController<SpeechResultRaw>();

    _speech.listen(
      localeId: languageCode == LanguageDetector.urdu ? 'ur-PK' : 'en-US',
      listenMode: ListenMode.confirmation,
      pauseFor: const Duration(seconds: 3),
      onResult: (SpeechRecognitionResult result) {
        if (controller.isClosed) return;
        controller.add(
          SpeechResultRaw(
            transcript: result.recognizedWords,
            speakerId: speakerId,
            isFinal: result.finalResult,
          ),
        );
        if (result.finalResult) controller.close();
      },
    );

    return controller.stream;
  }

  @override
  Future<void> stopListening() async {
    await _speech.stop();
  }
}
