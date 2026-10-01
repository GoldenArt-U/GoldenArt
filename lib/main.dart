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
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF800020),
            surface: const Color(0xFF141414),
          ),
          textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: AppTextStyles.heading3,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          dividerColor: const Color(0x1AFFFFFF),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            labelStyle: AppTextStyles.caption,
            hintStyle: AppTextStyles.caption,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0x33FFFFFF)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0x33FFFFFF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF800020), width: 2),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}