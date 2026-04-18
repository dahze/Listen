import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/core/usecases/usecase.dart';
import 'package:listen/features/auth/domain/entities/app_user.dart';
import 'package:listen/features/auth/domain/repositories/auth_repository.dart';

class SignUp implements UseCase<AppUser, SignUpParams> {
  final AuthRepository repository;
  const SignUp(this.repository);

  @override
  Future<Either<Failure, AppUser>> call(SignUpParams params) {
    return repository.signUp(email: params.email, password: params.password);
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;

  const SignUpParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
