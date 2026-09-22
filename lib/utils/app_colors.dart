import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

/// Palet aplikasi. Semua warna diambil dari sini, jangan tulis Color(...)
/// langsung di widget.
class AppColors {
  // Terang
  static const Color ink = Color(0xFF15171C);
  static const Color canvas = Color(0xFFF2F3F5);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color accent = Color(0xFFC2261F);
  static const Color muted = Color(0xFF6A7180);
  static const Color hairline = Color(0xFFDFE1E6);

  // Gelap
  static const Color inkDark = Color(0xFFECEEF2);
  static const Color canvasDark = Color(0xFF0F1114);
  static const Color paperDark = Color(0xFF181B20);
  static const Color accentDark = Color(0xFFFF6F61);
  static const Color mutedDark = Color(0xFF98A0AE);
  static const Color hairlineDark = Color(0xFF282C33);

  // Netral yang sama di kedua tema
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color scrim = Color(0xFF000000);
}

/// Tema terang & gelap. Judul memakai serif (Newsreader) karena ini aplikasi
/// berita; antarmuka dan teks kecil memakai IBM Plex Sans.
class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    ink: AppColors.ink,
    canvas: AppColors.canvas,
    paper: AppColors.paper,
    accent: AppColors.accent,
    muted: AppColors.muted,
    hairline: AppColors.hairline,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    ink: AppColors.inkDark,
    canvas: AppColors.canvasDark,
    paper: AppColors.paperDark,
    accent: AppColors.accentDark,
    muted: AppColors.mutedDark,
    hairline: AppColors.hairlineDark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color ink,
    required Color canvas,
    required Color paper,
    required Color accent,
    required Color muted,
    required Color hairline,
  }) {
    final headline = GoogleFonts.newsreaderTextTheme();
    final ui = GoogleFonts.ibmPlexSansTextTheme();

    final textTheme = TextTheme(
      // Judul lead story.
      displaySmall: headline.displaySmall!.copyWith(
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      // Judul halaman detail.
      headlineMedium: headline.headlineMedium!.copyWith(
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      // Judul berita di daftar.
      titleMedium: headline.titleMedium!.copyWith(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleSmall: ui.titleSmall!.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      // Isi artikel.
      bodyLarge: headline.bodyLarge!.copyWith(
        fontSize: 17,
        height: 1.7,
        color: ink,
      ),
      bodyMedium: ui.bodyMedium!.copyWith(
        fontSize: 14,
        height: 1.5,
        color: muted,
      ),
      // Sumber berita, waktu terbit, label tab.
      labelLarge: ui.labelLarge!.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: ink,
      ),
      labelMedium: ui.labelMedium!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
    );

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: accent,
          onPrimary: AppColors.onAccent,
          surface: paper,
          onSurface: ink,
          onSurfaceVariant: muted,
          outlineVariant: hairline,
          error: accent,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerTheme: DividerThemeData(color: hairline, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: ink, size: 22),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: textTheme.labelLarge!.copyWith(color: canvas),
        behavior: SnackBarBehavior.floating,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: AppColors.onAccent,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          textStyle: textTheme.labelLarge!.copyWith(
            color: AppColors.onAccent,
            fontSize: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paper,
        hintStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
    );
  }
}
