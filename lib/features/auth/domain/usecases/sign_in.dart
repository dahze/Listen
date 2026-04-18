import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/auth/domain/entities/app_user.dart';
import 'package:listen/features/auth/domain/repositories/auth_repository.dart';

class SignIn implements UseCase<AppUser, SignInParams> {
  final AuthRepository repository;
  const SignIn(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(SignInParams params) {
    return repository.signIn(email: params.email, password: params.password);
  }
}

class SignInParams extends Equatable {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
