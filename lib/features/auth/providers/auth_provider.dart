import 'package:abastecimento_p2/features/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authServices = AuthService();

  User? get currentUser => _authServices.currentUser;
  bool isLoading = false;
  String? error;

  Future<bool> signIn(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authServices.signInWithEmailPassword(email, password);

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      error = _handleException(e);
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      error = "Erro inesperado: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await _authServices.signUpWithEmailPassword(email, password);

      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      error = _handleException(e);
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      error = "Erro inesperado: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      await _authServices.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  String _handleException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      default:
        return 'Erro: ${e.message}';
    }
  }
}
