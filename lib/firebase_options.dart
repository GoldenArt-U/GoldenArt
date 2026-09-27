// lib/firebase_options.dart
//
// ─────────────────────────────────────────────────────────────────────────────
// INSTRUCTIONS: Paste your Firebase project credentials here.
//
// How to get them:
//   1. Open https://console.firebase.google.com
//   2. Select your project → Project Settings (⚙ gear icon) → General tab
//   3. Scroll to "Your apps" → select your Web app (or click "Add app" → Web)
//   4. Copy the firebaseConfig object values into this file.
//
// Fields to fill in (marked with TODO):
//   apiKey, authDomain, projectId, storageBucket,
//   messagingSenderId, appId
//
// ─────────────────────────────────────────────────────────────────────────────
// DO NOT commit real credentials to version control.
// This file is listed in .gitignore.
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

  // ── Web (also used for flutter build web) ──────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyCHEQ_N77EKPMcT55Zat-3KBUITDGg8SZQ',
    authDomain:        'golden-art-7f436.firebaseapp.com',
    projectId:         'golden-art-7f436',
    storageBucket:     'golden-art-7f436.firebasestorage.app',
    messagingSenderId: '255084862502',
    appId:             '1:255084862502:web:3b114e5d939aa476351ae7',
    measurementId:     'G-2DQ5DL1PXE',
  );

  // ── Android (optional — needed if you ever build for Android) ─────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'TODO_PASTE_API_KEY',
    authDomain:        'TODO_PASTE_AUTH_DOMAIN',
    projectId:         'TODO_PASTE_PROJECT_ID',
    storageBucket:     'TODO_PASTE_STORAGE_BUCKET',
    messagingSenderId: 'TODO_PASTE_MESSAGING_SENDER_ID',
    appId:             'TODO_PASTE_APP_ID',
  );

  // ── iOS (optional — needed if you ever build for iOS) ─────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'TODO_PASTE_API_KEY',
    authDomain:        'TODO_PASTE_AUTH_DOMAIN',
    projectId:         'TODO_PASTE_PROJECT_ID',
    storageBucket:     'TODO_PASTE_STORAGE_BUCKET',
    messagingSenderId: 'TODO_PASTE_MESSAGING_SENDER_ID',
    appId:             'TODO_PASTE_APP_ID',
    iosClientId:       'TODO_PASTE_IOS_CLIENT_ID',       // from GoogleService-Info.plist
    iosBundleId:       'TODO_PASTE_IOS_BUNDLE_ID',       // from GoogleService-Info.plist
  );
}
