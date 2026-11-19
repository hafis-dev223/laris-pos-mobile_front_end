import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna utama Laris POS (diambil dari desain Figma).
class AppColors {
  AppColors._();

  static const brand = Color(0xFF0B7F6E);
  static const brandPress = Color(0xFF086757);
  static const mint = Color(0xFFE2F3EF);
  static const bg = Color(0xFFF6F9F8);
  static const card = Colors.white;
  static const fg = Color(0xFF10201D);
  static const muted = Color(0xFF64756F);
  static const line = Color(0xFFDCE6E3);
  static const danger = Color(0xFFC23B3B);
}

OutlineInputBorder _border(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color, width: width),
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      primary: AppColors.brand,
      surface: AppColors.bg,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );

  return base.copyWith(
    textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme).apply(
      bodyColor: AppColors.fg,
      displayColor: AppColors.fg,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 14),
      border: _border(AppColors.line),
      enabledBorder: _border(AppColors.line),
      focusedBorder: _border(AppColors.brand, width: 1.6),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, width: 1.6),
      errorStyle: const TextStyle(color: AppColors.danger, fontSize: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brand,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
    ),
  );
}