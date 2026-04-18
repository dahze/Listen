import 'package:dartz/dartz.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> resetPassword({required String email});

  Future<Either<Failure, void>> signOut();

  Either<Failure, AppUser?> getCurrentUser();
}
