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
    'general', 'technology', 'business', 'sports',
    'health', 'science', 'entertainment',
  ];

  static const String defaultCountry = 'us';
  static const String appName = 'News App';
  static const String appVersion = '1.0.0';
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
