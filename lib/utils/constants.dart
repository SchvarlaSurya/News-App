import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static const String baseUrl = 'https://newsapi.org/v2';

  // Ambil API key dari environment variables
  static String get apiKey => dotenv.env['API_KEY'] ?? '';

  // Endpoints
  static const String topHeadlines = '/top-headlines';
  static const String everything = '/everything';

  // Categories
  static const List<String> categories = [
    'general',
    'technology',
    'business',
    'sports',
    'health',
    'science',
    'entertainment',
  ];

  /// Label kategori dalam bahasa Indonesia untuk tab di halaman utama.
  static const Map<String, String> categoryLabels = {
    'general': 'Terkini',
    'technology': 'Teknologi',
    'business': 'Bisnis',
    'sports': 'Olahraga',
    'health': 'Kesehatan',
    'science': 'Sains',
    'entertainment': 'Hiburan',
  };

  static String labelOf(String category) =>
      categoryLabels[category] ?? category;

  static const String defaultCountry = 'us';
  static const String appName = 'Warta';
  static const String appTagline = 'Kabar dunia, ringkas';
  static const String appVersion = '1.0.0';

  // Request
  static const int pageSize = 20;
  static const Duration requestTimeout = Duration(seconds: 15);

  /// NewsAPI paket gratis membatasi hasil yang bisa dipaginasi.
  static const int maxResults = 100;

  static const int maxSearchHistory = 8;
  static const Duration searchDebounce = Duration(milliseconds: 500);
}

/// Key penyimpanan lokal (shared_preferences).
class StorageKeys {
  static const String bookmarks = 'bookmarked_articles';
  static const String searchHistory = 'search_history';
  static const String darkMode = 'is_dark_mode';
}

/// Jarak antar elemen. Kelipatan 4 supaya ritme vertikalnya konsisten.
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 40;
}

class AppRadius {
  static const double sm = 6;
  static const double md = 12;
  static const double lg = 20;
}
