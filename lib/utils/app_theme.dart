import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
}

/// Spacing konsisten untuk padding/margin di semua screen.
class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
}

/// Border radius konsisten untuk card, chip, dan tombol.
class AppRadius {
  AppRadius._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 100.0;
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return TextTheme(
      // Judul di ArticleDetailScreen.
      titleLarge: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: textPrimary,
      ),
      // Judul artikel di ArticleCard (16-18sp bold).
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
      // Body content (14sp, line-height nyaman dibaca).
      bodyLarge: GoogleFonts.inter(fontSize: 16, height: 1.5, color: textPrimary),
      bodyMedium: GoogleFonts.inter(fontSize: 14, height: 1.6, color: textPrimary),
      // Source name + waktu publish (12sp, abu-abu).
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
        shadowColor: Colors.black.withValues(alpha: 0.12),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: BorderSide(color: primary.withValues(alpha: 0.4)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
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
