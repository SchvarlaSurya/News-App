import 'package:flutter/foundation.dart';

import '../models/article.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService;

  NewsProvider({NewsService? newsService})
      : _newsService = newsService ?? NewsService();

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedCategory = 'general';
  int _currentPage = 1;

  // Menyimpan query pencarian aktif (null berarti mode headlines, bukan search)
  String? _activeQuery;

  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  int get currentPage => _currentPage;

  /// Ambil top headlines untuk kategori aktif, reset list & halaman.
  Future<void> fetchTopHeadlines() async {
    _activeQuery = null;
    _currentPage = 1;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _newsService.getTopHeadlines(
        category: _selectedCategory,
        page: _currentPage,
      );
      _articles = result;
    } on NewsServiceException catch (e) {
      _errorMessage = e.message;
      _articles = [];
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tak terduga: $e';
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ganti kategori aktif lalu muat ulang headlines dari halaman 1.
  Future<void> changeCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    await fetchTopHeadlines();
  }

  /// Cari berita berdasarkan kata kunci, reset list & halaman.
  Future<void> searchNews(String query) async {
    _activeQuery = query;
    _currentPage = 1;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _newsService.searchNews(query, page: _currentPage);
      _articles = result;
    } on NewsServiceException catch (e) {
      _errorMessage = e.message;
      _articles = [];
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tak terduga: $e';
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Muat halaman berikutnya, tambahkan ke list yang sudah ada.
  /// Mengikuti mode aktif (search atau top headlines).
  Future<void> loadMore() async {
    if (_isLoading) return;

    final nextPage = _currentPage + 1;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Article> result;
      if (_activeQuery != null) {
        result = await _newsService.searchNews(_activeQuery!, page: nextPage);
      } else {
        result = await _newsService.getTopHeadlines(
          category: _selectedCategory,
          page: nextPage,
        );
      }
      _articles = [..._articles, ...result];
      _currentPage = nextPage;
    } on NewsServiceException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _newsService.dispose();
    super.dispose();
  }
}
