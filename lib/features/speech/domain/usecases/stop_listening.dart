import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/speech/domain/repositories/speech_repository.dart';

class StopListening implements UseCase<void, NoParams> {
  final SpeechRepository repository;
  const StopListening(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.stopListening();
  }
}
