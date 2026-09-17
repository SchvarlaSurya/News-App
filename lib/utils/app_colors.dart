import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

/// Palet warna terpusat. Jangan hardcode Color(...) di widget lain —
/// tambahkan token baru di sini kalau perlu.
class AppColors {
  AppColors._();

  static const primaryLight = Color(0xFF3D5AFE);
  static const primaryDark = Color(0xFF8C9EFF);

  static const backgroundLight = Color(0xFFF6F7FB);
  static const backgroundDark = Color(0xFF121212);

  static const surfaceLight = Colors.white;
  static const surfaceDark = Color(0xFF1E1E1E);

  static const errorLight = Color(0xFFD32F2F);
  static const errorDark = Color(0xFFEF9A9A);

  static const textPrimaryLight = Color(0xFF1A1B23);
  static const textPrimaryDark = Color(0xFFF2F2F5);

  static const textSecondaryLight = Color(0xFF6B7280);
  static const textSecondaryDark = Color(0xFFA3A3AD);

  // Overlay di atas gambar (tombol bulat, scrim gradient).
  static const onImage = Colors.white;
  static const scrim = Colors.black;

  // Shimmer
  static final shimmerBaseLight = Colors.grey.shade300;
  static final shimmerHighlightLight = Colors.grey.shade100;
  static final shimmerBaseDark = Colors.grey.shade700;
  static final shimmerHighlightDark = Colors.grey.shade600;
}

/// ThemeData light & dark yang dibangun dari [AppColors].
class AppTheme {
  AppTheme._();

  static ThemeData light = _build(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    error: AppColors.errorLight,
    textPrimary: AppColors.textPrimaryLight,
    textSecondary: AppColors.textSecondaryLight,
  );

  static ThemeData dark = _build(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    error: AppColors.errorDark,
    textPrimary: AppColors.textPrimaryDark,
    textSecondary: AppColors.textSecondaryDark,
  );

  static TextTheme _textTheme({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return TextTheme(
      // Judul di NewsDetailView.
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: textPrimary,
      ),
      // Judul artikel di NewsCard.
      titleMedium: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.5, color: textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.6, color: textPrimary),
      // Source name + waktu publish.
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color background,
    required Color surface,
    required Color error,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
    ).copyWith(
      primary: primary,
      surface: surface,
      error: error,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: _textTheme(textPrimary: textPrimary, textSecondary: textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: AppColors.scrim.withValues(alpha: 0.12),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.onImage,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.15),
        thickness: 1,
      ),
    );
  }
}
