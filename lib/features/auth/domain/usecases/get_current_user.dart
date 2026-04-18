import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/auth/domain/entities/app_user.dart';
import 'package:listen/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<AppUser?, NoParams> {
  final AuthRepository repository;
  const GetCurrentUser(this.repository);

  @override
  Future<Either<Failure, AppUser?>> call(NoParams params) async {
    return repository.getCurrentUser();
  }
}
