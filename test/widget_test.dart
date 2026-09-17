import 'package:flutter_test/flutter_test.dart';

import 'package:news_app/models/news_article.dart';
import 'package:news_app/models/news_response.dart';

void main() {
  test('NewsResponse parses articles and tolerates null fields', () {
    final response = NewsResponse.fromJson({
      'status': 'ok',
      'totalResults': 2,
      'articles': [
        {
          'source': {'id': null, 'name': 'Kompas'},
          'title': 'Judul',
          'url': 'https://example.com/a',
          'publishedAt': '2026-09-17T08:00:00Z',
        },
        {'source': null, 'title': null, 'url': null},
      ],
    });

    expect(response.status, 'ok');
    expect(response.articles, hasLength(2));
    expect(response.articles.first.source?.name, 'Kompas');
    expect(response.articles.last.source, isNull);
  });

  test('NewsResponse defaults articles to empty list', () {
    final response = NewsResponse.fromJson({'status': 'error'});

    expect(response.articles, isEmpty);
    expect(response.totalResults, isNull);
  });

  test('NewsArticle survives JSON round trip (bookmark storage)', () {
    final article = NewsArticle.fromJson({
      'source': {'id': 'bbc', 'name': 'BBC'},
      'title': 'Hello',
      'url': 'https://example.com/b',
      'urlToImage': 'https://example.com/b.jpg',
      'publishedAt': '2026-09-17T08:00:00Z',
    });

    final copy = NewsArticle.fromJson(article.toJson());

    expect(copy.url, article.url);
    expect(copy.source?.id, 'bbc');
    expect(copy.publishedAt, article.publishedAt);
  });
}
