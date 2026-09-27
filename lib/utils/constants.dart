import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFD97706);
  static const Color primaryLight = Color(0xFFF59E0B);
  static const Color dark = Color(0xFF0F172A);
  static const Color darkSecondary = Color(0xFF151E2E);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMedium = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color secondary = Color(0xFFF59E0B);
  static const Color starColor = Color(0xFFF59E0B);
}

class AppTextStyles {
  static final TextStyle displayLarge = GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, fontSize: 48, color: AppColors.dark);
  static final TextStyle heading1 = GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, fontSize: 32, color: AppColors.dark);
  static final TextStyle heading2 = GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, fontSize: 24, color: AppColors.dark);
  static final TextStyle heading3 = GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, fontSize: 20, color: AppColors.dark);
  static final TextStyle heading4 = GoogleFonts.playfairDisplay(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.dark);
  static final TextStyle body = GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: const Color(0xFF374151));
  static final TextStyle bodyMedium = GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.dark);
  static final TextStyle caption = GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: const Color(0xFF6B7280));
  static final TextStyle captionBold = GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: const Color(0xFF6B7280));
  static final TextStyle price = GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.dark);
  static final TextStyle priceLarge = GoogleFonts.playfairDisplay(fontWeight: FontWeight.w700, fontSize: 28, color: AppColors.dark);
  static final TextStyle button = GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white);
  static final TextStyle badge = GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 10, color: Colors.white, letterSpacing: 1.0);
  static final TextStyle navLabel = GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12, color: const Color(0xFF6B7280));
}

class AppConstants {
  static const String appName = 'GoldenArt';
  static const String tagline = 'Rare & Unique Finds in Tunisia';
  static const double deliveryFeeValue = 7.5;
  static const String currency = 'TND';
  static String formatMoney(double amount, {String currency = 'TND '}) {
    if (currency.isEmpty) return amount.toStringAsFixed(2);
    return '$currency${amount.toStringAsFixed(2)}';
  }
}