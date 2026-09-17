import 'package:flutter_test/flutter_test.dart';

import 'package:news_app/models/news_article.dart';
import 'package:news_app/models/news_response.dart';

void main() {
  test('NewsResponse parses articles and drops removed ones', () {
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
        {
          'source': {'id': null, 'name': '[Removed]'},
          'title': '[Removed]',
          'url': 'https://removed.com',
        },
      ],
    });

    expect(response.isOk, isTrue);
    expect(response.articles, hasLength(1));
    expect(response.articles.first.source.name, 'Kompas');
  });

  test('NewsArticle survives JSON round trip (bookmark storage)', () {
    final article = NewsArticle.fromJson({
      'source': {'id': 'bbc', 'name': 'BBC'},
      'title': 'Hello',
      'url': 'https://example.com/b',
      'urlToImage': 'https://example.com/b.jpg',
      'publishedAt': '2026-09-17T08:00:00.000Z',
    });

    final copy = NewsArticle.fromJson(article.toJson());

    expect(copy.url, article.url);
    expect(copy.source.id, 'bbc');
    expect(copy.publishedAt, article.publishedAt);
    expect(copy.hasImage, isTrue);
  });
}
