import 'package:dartz/dartz.dart';
import 'package:listen/core/error/exceptions.dart';
import 'package:listen/core/error/failures.dart';
import 'package:listen/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:listen/features/auth/domain/entities/app_user.dart';
import 'package:listen/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthFirebaseDatasource datasource;
  const AuthRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await datasource.signIn(email: email, password: password);
      return Right(AppUser(id: user.uid, email: user.email ?? ''));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await datasource.signUp(email: email, password: password);
      return Right(AppUser(id: user.uid, email: user.email ?? ''));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await datasource.resetPassword(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await datasource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Either<Failure, AppUser?> getCurrentUser() {
    try {
      final user = datasource.getCurrentUser();
      if (user == null) return const Right(null);
      return Right(AppUser(id: user.uid, email: user.email ?? ''));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }
}
