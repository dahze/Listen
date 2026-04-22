import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/features/speech/domain/entities/speech_result.dart';
import 'package:listen/features/speech/domain/repositories/speech_repository.dart';

class ListenSpeech {
  final SpeechRepository repository;
  const ListenSpeech(this.repository);

  Stream<Either<Failure, SpeechResult>> call(ListenSpeechParams params) {
    return repository.startListening(
      speakerId: params.speakerId,
      languageCode: params.languageCode,
    );
  }
}

class ListenSpeechParams extends Equatable {
  final String speakerId;
  final String languageCode;

  const ListenSpeechParams({
    required this.speakerId,
    required this.languageCode,
  });

  @override
  List<Object> get props => [speakerId, languageCode];
}
