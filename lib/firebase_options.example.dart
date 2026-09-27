// lib/firebase_options.example.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// TEMPLATE — safe to commit.
// Copy this file to  lib/firebase_options.dart  and fill in real values.
// lib/firebase_options.dart is listed in .gitignore and must NEVER be committed.
//
// Where to get the values:
//   https://console.firebase.google.com
//   → Your project → ⚙ Project Settings → General → Your apps → Web app
//   → Copy the firebaseConfig values below.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            '',   // from Firebase console
    authDomain:        '',   // e.g. your-project.firebaseapp.com
    projectId:         '',   // e.g. your-project-id
    storageBucket:     '',   // e.g. your-project.appspot.com
    messagingSenderId: '',   // numeric sender ID
    appId:             '',   // e.g. 1:123:web:abc
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            '',
    authDomain:        '',
    projectId:         '',
    storageBucket:     '',
    messagingSenderId: '',
    appId:             '',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            '',
    authDomain:        '',
    projectId:         '',
    storageBucket:     '',
    messagingSenderId: '',
    appId:             '',
    iosClientId:       '',   // from GoogleService-Info.plist → CLIENT_ID
    iosBundleId:       '',   // from GoogleService-Info.plist → BUNDLE_ID
  );
}
