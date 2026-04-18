import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:listen/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:listen/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:listen/features/auth/domain/repositories/auth_repository.dart';
import 'package:listen/features/auth/domain/usecases/get_current_user.dart';
import 'package:listen/features/auth/domain/usecases/sign_in.dart';
import 'package:listen/features/auth/domain/usecases/sign_out.dart';
import 'package:listen/features/auth/domain/usecases/sign_up.dart';
import 'package:listen/features/auth/domain/usecases/reset_password.dart';
import 'package:listen/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ─── External ───────────────────────────────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ─── Auth ────────────────────────────────────────────────
  // Datasource
  sl.registerLazySingleton<AuthFirebaseDatasource>(
    () => AuthFirebaseDatasourceImpl(sl()),
  );
  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  // Use cases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => ResetPassword(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  // BLoC — factory so every instance is fresh
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      resetPassword: sl(),
    ),
  );
}
