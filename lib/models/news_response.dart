import 'package:news_app/models/news_article.dart';

class NewsResponse {
  final String? status;
  final int? totalResults;
  final List<NewsArticle> articles;

  NewsResponse({this.status, this.totalResults, this.articles = const []});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'],
      totalResults: json['totalResults'],
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((e) => NewsArticle.fromJson(e))
              .toList() ??
          [],
    );
  }
}
