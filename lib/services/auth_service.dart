import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static bool get isFirebaseReady => Firebase.apps.isNotEmpty;
  FirebaseAuth? get _auth => isFirebaseReady ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _db => isFirebaseReady ? FirebaseFirestore.instance : null;

  static bool _mockLoggedIn = true; // Auto-login in demo mode so user can immediately test!
  static final StreamController<bool> _mockAuthStateController =
      StreamController<bool>.broadcast();

  User? get currentUser => isFirebaseReady ? _auth?.currentUser : null;
  bool get isDemoLoggedIn => _mockLoggedIn;

  Stream<User?> get authStateChanges {
    if (isFirebaseReady) {
      return _auth!.authStateChanges();
    }
    return const Stream.empty();
  }

  Stream<bool> get mockAuthStateChanges =>
      _mockAuthStateController.stream.startWith(_mockLoggedIn);

  Future<void> signInWithEmail(String email, String password) async {
    if (isFirebaseReady) {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      return;
    }
    _mockLoggedIn = true;
    _mockAuthStateController.add(true);
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    if (isFirebaseReady) {
      final cred = await _auth!.createUserWithEmailAndPassword(
          email: email, password: password);
      await cred.user?.updateDisplayName(name);
      await _db!.collection('users').doc(cred.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
        'availableBalance': 0.0,
        'pendingBalance': 0.0,
        'isSeller': false,
        'status': 'active',
      });
      return;
    }
    _mockLoggedIn = true;
    _mockAuthStateController.add(true);
  }

  Future<void> signInWithGoogle() async {
    if (isFirebaseReady) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      final cred = await _auth!.signInWithPopup(authProvider);
      
      // If it's a new user, create their document
      final doc = await _db!.collection('users').doc(cred.user?.uid).get();
      if (!doc.exists) {
        await _db!.collection('users').doc(cred.user?.uid).set({
          'name': cred.user?.displayName ?? 'Utilisateur',
          'email': cred.user?.email ?? '',
          'createdAt': Timestamp.now(),
          'availableBalance': 0.0,
          'pendingBalance': 0.0,
          'isSeller': false,
          'status': 'active',
        });
      }
      return;
    }
    _mockLoggedIn = true;
    _mockAuthStateController.add(true);
  }

  // Web Phone Auth requires RecaptchaVerifier, which is usually handled in the UI layer.
  // This is the backend call that returns a ConfirmationResult.
  Future<ConfirmationResult?> signInWithPhone(String phoneNumber, RecaptchaVerifier verifier) async {
    if (isFirebaseReady) {
      return await _auth!.signInWithPhoneNumber(phoneNumber, verifier);
    }
    return null;
  }

  Future<void> signOut() async {
    if (isFirebaseReady) {
      await _auth!.signOut();
      return;
    }
    _mockLoggedIn = false;
    _mockAuthStateController.add(false);
  }

  Future<void> sendPasswordReset(String email) async {
    if (isFirebaseReady) {
      await _auth!.sendPasswordResetEmail(email: email);
    }
  }
}

extension _StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T initial) async* {
    yield initial;
    yield* this;
  }
}
