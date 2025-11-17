import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> signOut() async {
      await _firebaseAuth.signOut();
  }
}