import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/features/speech/domain/entities/speech_result.dart';

abstract class SpeechRepository {
  /// Emits partial results as the user speaks, then a final result
  /// with isFinal=true when they stop.
  Stream<Either<Failure, SpeechResult>> startListening({
    required String speakerId,
    required String languageCode,
  });

  Future<Either<Failure, void>> stopListening();

  Future<Either<Failure, bool>> requestPermission();
}
