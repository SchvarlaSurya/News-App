import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/models/news_response.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NewsService palsu supaya test tidak memanggil jaringan sungguhan.
class FakeNewsService extends NewsService {
  List<NewsArticle> result;
  NewsServiceException? failure;
  int headlineCalls = 0;
  int lastPage = 0;

  FakeNewsService({this.result = const [], this.failure});

  @override
  Future<NewsResponse> getTopHeadlines({
    String country = Constants.defaultCountry,
    String? category,
    int page = 1,
    int pageSize = Constants.pageSize,
  }) async {
    headlineCalls++;
    lastPage = page;
    if (failure != null) throw failure!;
    return NewsResponse(status: 'ok', totalResults: 80, articles: result);
  }

  @override
  void dispose() {}
}

NewsArticle article(String id) => NewsArticle(
  title: 'Judul $id',
  url: 'https://example.com/$id',
  publishedAt: '2026-09-17T08:00:00Z',
  source: Source(id: id, name: 'Sumber $id'),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('NewsResponse', () {
    test('membaca artikel dan menoleransi field kosong', () {
      final response = NewsResponse.fromJson({
        'status': 'ok',
        'totalResults': 2,
        'articles': [
          {
            'source': {'id': null, 'name': 'Reuters'},
            'title': 'Judul',
            'url': 'https://example.com/a',
            'publishedAt': '2026-09-17T08:00:00Z',
          },
          {'source': null, 'title': null, 'url': null},
        ],
      });

      expect(response.status, 'ok');
      expect(response.articles, hasLength(2));
      expect(response.articles.first.source?.name, 'Reuters');
      expect(response.articles.last.isUsable, isFalse);
    });

    test('articles jadi list kosong saat data tidak ada', () {
      final response = NewsResponse.fromJson({'status': 'error'});
      expect(response.articles, isEmpty);
    });
  });

  group('NewsArticle', () {
    test('tetap utuh setelah bolak-balik JSON (untuk bookmark)', () {
      final copy = NewsArticle.fromJson(article('a').toJson());

      expect(copy.url, 'https://example.com/a');
      expect(copy.source?.name, 'Sumber a');
      expect(copy.publishedAt, '2026-09-17T08:00:00Z');
    });

    test('publishedDate membaca ISO 8601 dan menolak data rusak', () {
      expect(
        NewsArticle(publishedAt: '2020-01-15T08:00:00Z').publishedDate,
        DateTime.utc(2020, 1, 15, 8).toLocal(),
      );
      expect(NewsArticle(publishedAt: 'bukan tanggal').publishedDate, isNull);
      expect(NewsArticle().publishedDate, isNull);
    });

    test('readableContent membuang penanda potongan NewsAPI', () {
      final item = NewsArticle(content: 'Isi berita. [+2417 chars]');
      expect(item.readableContent, 'Isi berita.');
    });
  });

  group('NewsController', () {
    test('fetchHeadlines mengisi daftar berita', () async {
      final controller = NewsController(
        newsService: FakeNewsService(result: [article('a'), article('b')]),
      );

      await controller.fetchHeadlines();

      expect(controller.articles, hasLength(2));
      expect(controller.errorMessage.value, isNull);
      expect(controller.hasMore.value, isTrue);
    });

    test('pesan error tampil saat service gagal', () async {
      final controller = NewsController(
        newsService: FakeNewsService(
          failure: NewsServiceException('Tidak ada koneksi internet.'),
        ),
      );

      await controller.fetchHeadlines();

      expect(controller.articles, isEmpty);
      expect(controller.errorMessage.value, 'Tidak ada koneksi internet.');
    });

    test('loadMoreHeadlines meminta halaman berikutnya', () async {
      final service = FakeNewsService(result: [article('a')]);
      final controller = NewsController(newsService: service);

      await controller.fetchHeadlines();
      await controller.loadMoreHeadlines();

      expect(service.lastPage, 2);
      expect(controller.articles, hasLength(2));
    });

    test('berita tersimpan dipakai saat permintaan gagal', () async {
      final service = FakeNewsService(result: [article('a'), article('b')]);
      final controller = NewsController(newsService: service);

      // Unduhan pertama berhasil dan mengisi simpanan lokal.
      await controller.fetchHeadlines();
      expect(controller.isShowingCache.value, isFalse);

      // Permintaan berikutnya gagal, tapi daftar tetap terisi dari simpanan.
      service.failure = NewsServiceException('Tidak ada koneksi internet.');
      final offline = NewsController(newsService: service);
      await offline.fetchHeadlines();

      expect(offline.articles, hasLength(2));
      expect(offline.isShowingCache.value, isTrue);
      expect(offline.errorMessage.value, isNull);
      expect(offline.hasMore.value, isFalse);
    });

    test('artikel yang dibuka ditandai sudah dibaca', () async {
      final controller = NewsController(newsService: FakeNewsService());
      final item = article('a');

      expect(controller.isRead(item), isFalse);
      await controller.markAsRead(item);
      expect(controller.isRead(item), isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList(StorageKeys.readArticles),
        contains('https://example.com/a'),
      );
    });

    test('ukuran teks berputar dan tersimpan', () async {
      final controller = NewsController(newsService: FakeNewsService());

      expect(controller.readerScale.value, 1.0);
      await controller.cycleReaderScale();
      expect(controller.readerScale.value, Constants.readerScales[2]);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getDouble(StorageKeys.readerScale),
        Constants.readerScales[2],
      );
    });

    test('relatedTo tidak menyertakan artikel yang sedang dibuka', () async {
      final controller = NewsController(
        newsService: FakeNewsService(
          result: [article('a'), article('b'), article('c')],
        ),
      );
      await controller.fetchHeadlines();

      final related = controller.relatedTo(article('a'));

      expect(related, hasLength(2));
      expect(
        related.map((item) => item.url),
        isNot(contains('https://example.com/a')),
      );
    });

    test('bookmark tersimpan di penyimpanan lokal', () async {
      final controller = NewsController(newsService: FakeNewsService());
      final item = article('a');

      expect(controller.isBookmarked(item), isFalse);
      await controller.toggleBookmark(item);
      expect(controller.isBookmarked(item), isTrue);

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(StorageKeys.bookmarks) ?? [];
      expect(stored, hasLength(1));
      expect(jsonDecode(stored.first)['url'], 'https://example.com/a');

      await controller.toggleBookmark(item);
      expect(controller.isBookmarked(item), isFalse);
    });
  });
}
