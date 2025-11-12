import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Usuário não encontrado.');
        case 'wrong-password':
          throw Exception('Senha incorreta.');
        case 'network-request-failed':
          throw Exception('Erro de conexão. Verifique sua internet.');
        default:
          throw Exception('Erro ao entrar. Tente novamente.');
      }
    }
  }

  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('E-mail já está em uso.');
        case 'invalid-email':
          throw Exception('E-mail inválido!');
        case 'weak-password':
          throw Exception('Senha fraca (mínimo 6 caracteres).');
        case 'network-request-failed':
          throw Exception('Erro de conexão. Verifique sua internet.');
        default:
          throw Exception('Erro ao cadastrar. Tente novamente.');
      }
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}