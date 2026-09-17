import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi terpusat: base URL, endpoint, kategori, dan API key.
class Constants {
  Constants._();

  static const String baseUrl = 'https://newsapi.org/v2';

  // Ambil API key dari environment variables (.env).
  // Getter, bukan const, supaya dibaca saat runtime setelah dotenv.load().
  // Daftar & ambil API key di https://newsapi.org/account
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Endpoints
  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  // Categories (dipakai untuk filter chip di halaman home)
  static const List<String> categories = [
    'general', 'technology', 'business', 'sports',
    'health', 'science', 'entertainment',
  ];

  /// Pseudo-kategori untuk menampilkan artikel yang di-bookmark (bukan dari API).
  static const String bookmarksCategory = 'bookmarks';

  static const String defaultCountry = 'us';
  static const String appName = 'News App';
  static const String appVersion = '1.0.0';

  static const int pageSize = 20;
  static const Duration timeout = Duration(seconds: 10);
}

/// Key untuk shared_preferences.
class StorageKeys {
  StorageKeys._();

  static const String bookmarks = 'bookmarked_articles';
  static const String isDarkMode = 'is_dark_mode';
}

/// Spacing konsisten untuk padding/margin di semua view.
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
