import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:artisan_market/firebase_options.dart';
import 'package:artisan_market/providers/auth_provider.dart';
import 'package:artisan_market/providers/cart_provider.dart';
import 'package:artisan_market/screens/splash_screen.dart';
import 'package:artisan_market/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase initialization ─────────────────────────────────────────────
  // Guards against double-initialization (hot-reload safe).
  // If the options still contain 'TODO_' placeholders the app runs in
  // offline / mock mode automatically — no crash.
  final options = DefaultFirebaseOptions.currentPlatform;
  final isPlaceholder = options.apiKey.startsWith('TODO_');

  if (!isPlaceholder) {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
    } catch (e) {
      // Initialisation failed — app continues in mock/demo mode.
      debugPrint('[GoldenArt] Firebase init failed: $e');
    }
  } else {
    debugPrint(
        '[GoldenArt] Firebase credentials not set — running in demo/mock mode. '
        'Fill in lib/firebase_options.dart to enable real Firebase.');
  }
  // ─────────────────────────────────────────────────────────────────────────

  runApp(const GoldenArtApp());
}

class GoldenArtApp extends StatelessWidget {
  const GoldenArtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'GoldenArt',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFD97706),
            surface: const Color(0xFFF9FAFB),
          ),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: false,
            titleTextStyle: AppTextStyles.heading3,
            iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}