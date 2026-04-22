import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/speech/domain/repositories/speech_repository.dart';

class RequestPermission implements UseCase<bool, NoParams> {
  final SpeechRepository repository;
  const RequestPermission(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.requestPermission();
  }
}
