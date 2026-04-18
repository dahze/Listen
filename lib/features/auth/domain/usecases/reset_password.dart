import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/auth/domain/repositories/auth_repository.dart';

class ResetPassword implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPassword(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return repository.resetPassword(email: params.email);
  }
}

class ResetPasswordParams {
  final String email;

  ResetPasswordParams({required this.email});
}
