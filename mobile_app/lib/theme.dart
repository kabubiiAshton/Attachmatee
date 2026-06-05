import 'package:flutter/material.dart';

/// Centralised colours and theme so screens stay consistent.
class AppColors {
  static const ink = Color(0xFF1D2B2A);
  static const teal = Color(0xFF1F6F6A);
  static const tealDark = Color(0xFF154D49);
  static const paper = Color(0xFFF4F1EA);
  static const surface = Color(0xFFFBFAF6);
  static const line = Color(0xFFDDD8CC);
  static const inkSoft = Color(0xFF4A5A58);
  static const muted = Color(0xFF8A9794);

  static const ok = Color(0xFF2F7D4F);
  static const okSoft = Color(0xFFE0EFE5);
  static const warn = Color(0xFF9A7322);
  static const warnSoft = Color(0xFFF4ECD8);
  static const danger = Color(0xFFA8403A);
  static const dangerSoft = Color(0xFFF3E2E0);
  static const tealSoft = Color(0xFFE2EFED);
}

/// Maps a status string to a (bg, fg) colour pair for badges.
({Color bg, Color fg}) statusColors(String status) {
  switch (status.toLowerCase()) {
    case 'approved':
    case 'accepted':
    case 'verified':
      return (bg: AppColors.okSoft, fg: AppColors.ok);
    case 'pending':
      return (bg: AppColors.warnSoft, fg: AppColors.warn);
    case 'rejected':
    case 'closed':
      return (bg: AppColors.dangerSoft, fg: AppColors.danger);
    case 'shortlisted':
      return (bg: AppColors.tealSoft, fg: AppColors.tealDark);
    default:
      return (bg: const Color(0xFFECE8DD), fg: AppColors.inkSoft);
  }
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.teal,
      primary: AppColors.teal,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.paper,
    fontFamily: 'Roboto',
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.ink,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
