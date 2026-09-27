// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // This project is deployed as a Flutter Web app.
    // Android / iOS configs can be added here when needed.
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyCHEQ_N77EKPMcT55Zat-3KBUITDGg8SZQ',
    authDomain:        'golden-art-7f436.firebaseapp.com',
    projectId:         'golden-art-7f436',
    storageBucket:     'golden-art-7f436.firebasestorage.app',
    messagingSenderId: '255084862502',
    appId:             '1:255084862502:web:3b114e5d939aa476351ae7',
    measurementId:     'G-2DQ5DL1PXE',
  );
}