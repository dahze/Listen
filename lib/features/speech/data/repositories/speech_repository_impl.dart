import 'package:dartz/dartz.dart';
import 'package:listen/core/error/exceptions.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/utils/language_detector.dart';
import 'package:listen/features/speech/data/datasources/speech_datasource.dart';
import 'package:listen/features/speech/domain/entities/speech_result.dart';
import 'package:listen/features/speech/domain/repositories/speech_repository.dart';

class SpeechRepositoryImpl implements SpeechRepository {
  final SpeechDatasource datasource;
  const SpeechRepositoryImpl(this.datasource);

  @override
  Stream<Either<Failure, SpeechResult>> startListening({
    required String speakerId,
    required String languageCode,
  }) {
    try {
      return datasource
          .startListening(speakerId: speakerId, languageCode: languageCode)
          .map(
            (raw) => Right<Failure, SpeechResult>(
              SpeechResult(
                transcript: raw.transcript,
                speakerId: raw.speakerId,
                isFinal: raw.isFinal,
                detectedLang: LanguageDetector.detect(raw.transcript),
              ),
            ),
          )
          .handleError((e) {
            if (e is SpeechException) {
              return Left<Failure, SpeechResult>(SpeechFailure(e.message));
            }
            return Left<Failure, SpeechResult>(
              SpeechFailure('Unexpected speech error: $e'),
            );
          });
    } on SpeechException catch (e) {
      return Stream.value(Left(SpeechFailure(e.message)));
    }
  }

  @override
  Future<Either<Failure, void>> stopListening() async {
    try {
      await datasource.stopListening();
      return const Right(null);
    } on SpeechException catch (e) {
      return Left(SpeechFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> requestPermission() async {
    try {
      final granted = await datasource.requestPermission();
      return Right(granted);
    } on SpeechException catch (e) {
      return Left(SpeechFailure(e.message));
    }
  }
}
