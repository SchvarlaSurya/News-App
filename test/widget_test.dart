import 'package:flutter_test/flutter_test.dart';

import 'package:news_app/models/news_article.dart';
import 'package:news_app/models/news_response.dart';
import 'package:news_app/widgets/news_card.dart';

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

  test('parsePublishedAt handles valid, empty, broken and future dates', () {
    final parsed = NewsCard.parsePublishedAt('2020-01-15T08:00:00Z');
    expect(parsed, DateTime.utc(2020, 1, 15, 8).toLocal());
    expect(parsed!.isUtc, isFalse);

    expect(NewsCard.parsePublishedAt(null), isNull);
    expect(NewsCard.parsePublishedAt(''), isNull);
    expect(NewsCard.parsePublishedAt('bukan tanggal'), isNull);

    final future = DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String();
    expect(NewsCard.parsePublishedAt(future)!.isAfter(DateTime.now()), isFalse);
  });

  test('NewsArticle parses source when present', () {
    final article = NewsArticle.fromJson({
      'source': {'id': 'bbc', 'name': 'BBC'},
      'title': 'Hello',
      'url': 'https://example.com/b',
      'urlToImage': 'https://example.com/b.jpg',
      'publishedAt': '2026-09-17T08:00:00Z',
    });

    expect(article.url, 'https://example.com/b');
    expect(article.source?.id, 'bbc');
    expect(article.publishedAt, '2026-09-17T08:00:00Z');
  });
}
