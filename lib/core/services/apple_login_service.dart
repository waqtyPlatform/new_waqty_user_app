import 'package:firebase_auth/firebase_auth.dart';

class AppleLoginService {
  final FirebaseAuth _firebaseAuth;

  AppleLoginService(this._firebaseAuth);

  Future<UserCredential> signIn() async {
    final appleProvider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    return _firebaseAuth.signInWithProvider(appleProvider);
  }

  Future<String?> currentIdToken({bool forceRefresh = true}) {
    return _firebaseAuth.currentUser?.getIdToken(forceRefresh) ??
        Future.value();
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
