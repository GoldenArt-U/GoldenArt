import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep Burgundy Accent
  static const Color primary = Color(0xFF800020);
  static const Color primaryLight = Color(0xFFA31A3F);

  // Dark Luxury Backgrounds
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color dark = Color(0xFF000000);
  static const Color darkSecondary = Color(0xFF1A1A1A);

  // Borders & Dividers — translucent white for glass effect
  static const Color border = Color(0x33FFFFFF);
  static const Color divider = Color(0x1AFFFFFF);

  // Typography (inverted for dark backgrounds)
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textMedium = Color(0xFFA1A1AA);
  static const Color textLight = Color(0xFF71717A);

  // States
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color secondary = Color(0xFF800020);
  static const Color starColor = Color(0xFFD97706);
}

class AppTextStyles {
  // Massive editorial hero typography
  static final TextStyle displayLarge = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w900,
    fontSize: 64,
    color: AppColors.textDark,
    height: 1.0,
    letterSpacing: 2,
  );

  static final TextStyle heading1 = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w700,
    fontSize: 32,
    color: AppColors.textDark,
  );
  static final TextStyle heading2 = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w700,
    fontSize: 24,
    color: AppColors.textDark,
  );
  static final TextStyle heading3 = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: AppColors.textDark,
  );
  static final TextStyle heading4 = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.textDark,
  );

  static final TextStyle body = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: AppColors.textMedium,
  );
  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    color: AppColors.textDark,
  );
  static final TextStyle caption = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: AppColors.textLight,
  );
  static final TextStyle captionBold = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 12,
    color: AppColors.textLight,
  );

  static final TextStyle price = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w700,
    fontSize: 16,
    color: AppColors.primary,
  );
  static final TextStyle priceLarge = GoogleFonts.playfairDisplay(
    fontWeight: FontWeight.w700,
    fontSize: 28,
    color: AppColors.primary,
  );
  static final TextStyle button = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    fontSize: 14,
    color: Colors.white,
    letterSpacing: 1,
  );
  static final TextStyle badge = GoogleFonts.inter(
    fontWeight: FontWeight.w700,
    fontSize: 10,
    color: Colors.white,
    letterSpacing: 1.5,
  );
  static final TextStyle navLabel = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: AppColors.textMedium,
  );
}

class AppConstants {
  static const String appName = 'GoldenArt';
  static const String tagline = 'Tunisian 1-OF-1 Collection';
  static const double deliveryFeeValue = 7.5;
  static const String currency = 'TND';

  static String formatMoney(double amount, {String currency = 'TND '}) {
    if (currency.isEmpty) return amount.toStringAsFixed(2);
    return '$currency${amount.toStringAsFixed(2)}';
  }
}