import 'package:firebase_auth/firebase_auth.dart';
import 'package:listen/core/error/exceptions.dart';

abstract class AuthFirebaseDatasource {
  Future<User> signIn({required String email, required String password});
  Future<User> signUp({required String email, required String password});
  Future<void> resetPassword({required String email});
  Future<void> signOut();
  User? getCurrentUser();
}

class AuthFirebaseDatasourceImpl implements AuthFirebaseDatasource {
  final FirebaseAuth _auth;
  const AuthFirebaseDatasourceImpl(this._auth);

  @override
  Future<User> signIn({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException('Sign in failed — no user returned');
      }
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    }
  }

  @override
  Future<User> signUp({required String email, required String password}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw const AuthException('Sign up failed — no user returned');
      }
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed');
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Password reset failed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign out failed');
    }
  }

  @override
  User? getCurrentUser() => _auth.currentUser;
}
