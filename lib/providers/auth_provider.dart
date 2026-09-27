import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:artisan_market/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isDemoLoggedIn = true; // Enabled by default for immediate testing
  bool _loading = false;
  String? _error;
  bool _isSeller = false;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn =>
      AuthService.isFirebaseReady ? (_user != null) : _isDemoLoggedIn;
  String get userId =>
      AuthService.isFirebaseReady ? (_user?.uid ?? '') : 'demo_artisan_user';
  String get userName => AuthService.isFirebaseReady
      ? (_user?.displayName ?? 'Utilisateur')
      : 'Client Artisanat';
  bool get isSeller => AuthService.isFirebaseReady ? _isSeller : _isDemoLoggedIn;

  AuthProvider() {
    if (AuthService.isFirebaseReady) {
      _authService.authStateChanges.listen((user) async {
        _user = user;
        if (user != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          _isSeller = doc.data()?['isSeller'] ?? false;
        } else {
          _isSeller = false;
        }
        notifyListeners();
      });
    } else {
      _authService.mockAuthStateChanges.listen((loggedIn) {
        _isDemoLoggedIn = loggedIn;
        notifyListeners();
      });
    }
  }

  Future<void> upgradeToSeller() async {
    if (!AuthService.isFirebaseReady || _user == null) {
      _isDemoLoggedIn = true;
      _isSeller = true;
      notifyListeners();
      return;
    }
    
    _loading = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'isSeller': true,
      }, SetOptions(merge: true));
      _isSeller = true;
    } catch (e) {
      _error = 'Failed to upgrade account: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Google Sign-In Failed: $e';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signInWithEmail(email, password);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Une erreur inattendue est survenue. Veuillez réessayer.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signUpWithEmail(email, password, name);
      _loading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _loading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Une erreur inattendue est survenue. Veuillez réessayer.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Maps Firebase Auth error codes to user-friendly French messages.
  /// Covers Task 2 required codes: email-already-in-use, invalid-email,
  /// weak-password, network-request-failed.
  static String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée. Essayez de vous connecter.';
      case 'invalid-email':
        return 'Adresse email invalide. Vérifiez le format (ex: nom@exemple.com).';
      case 'weak-password':
        return 'Mot de passe trop faible. Utilisez au moins 6 caractères.';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email. Inscrivez-vous d\'abord.';
      case 'wrong-password':
        return 'Mot de passe incorrect. Réessayez ou réinitialisez-le.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion internet.';
      case 'too-many-requests':
        return 'Trop de tentatives. Attendez quelques minutes avant de réessayer.';
      case 'user-disabled':
        return 'Ce compte a été désactivé. Contactez le support.';
      case 'operation-not-allowed':
        return 'Connexion par email désactivée. Activez-la dans la console Firebase.';
      default:
        return 'Erreur d\'authentification ($code). Réessayez.';
    }
  }
}
