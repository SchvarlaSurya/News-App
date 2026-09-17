import 'news_article.dart';

/// Respons dari endpoint NewsAPI (`/top-headlines` & `/everything`).
/// Kalau [status] == 'error', [code] & [message] berisi detail error.
class NewsResponse {
  final String status;
  final int totalResults;
  final List<NewsArticle> articles;
  final String? code;
  final String? message;

  const NewsResponse({
    required this.status,
    this.totalResults = 0,
    this.articles = const [],
    this.code,
    this.message,
  });

  bool get isOk => status == 'ok';

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final articlesJson = json['articles'] as List<dynamic>? ?? [];

    return NewsResponse(
      status: json['status'] ?? 'error',
      totalResults: json['totalResults'] ?? 0,
      articles: articlesJson
          .map((item) => NewsArticle.fromJson(item as Map<String, dynamic>))
          // NewsAPI kadang kirim artikel yang sudah dihapus.
          .where((article) => article.title != '[Removed]' && article.url.isNotEmpty)
          .toList(),
      code: json['code'],
      message: json['message'],
    );
  }
}
