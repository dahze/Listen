import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/auth/domain/repositories/auth_repository.dart';

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;
  const SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
