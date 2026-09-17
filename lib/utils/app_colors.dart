import 'package:flutter/material.dart';

/// Palet warna terpusat. Jangan hardcode Color(...) di widget lain —
/// tambahkan token baru di sini kalau perlu.
class AppColors {
  AppColors._();

  static const primary = Color(0xFF3D5AFE);
  static const background = Color(0xFFF6F7FB);

  // Overlay di atas gambar (teks/tombol putih, scrim gradient gelap).
  static const onImage = Colors.white;
  static const scrim = Colors.black;

  // Shimmer
  static final shimmerBaseLight = Colors.grey.shade300;
  static final shimmerHighlightLight = Colors.grey.shade100;
  static final shimmerBaseDark = Colors.grey.shade700;
  static final shimmerHighlightDark = Colors.grey.shade600;
}
