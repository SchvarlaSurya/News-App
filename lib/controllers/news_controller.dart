import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/models/news_response.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State seluruh aplikasi: daftar berita per kategori, pencarian, bookmark,
/// dan pilihan tema.
class NewsController extends GetxController {
  final NewsService _newsService;

  NewsController({NewsService? newsService})
    : _newsService = newsService ?? NewsService();

  // --- Beranda ---
  final articles = <NewsArticle>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final selectedCategory = Constants.categories.first.obs;
  final hasMore = true.obs;
  int _page = 1;

  // Naik tiap permintaan baru; respons dari permintaan lama diabaikan supaya
  // hasil kategori sebelumnya tidak menimpa kategori yang sedang dibuka.
  int _requestId = 0;

  // --- Pencarian ---
  final searchResults = <NewsArticle>[].obs;
  final searchQuery = ''.obs;
  final isSearchLoading = false.obs;
  final isSearchLoadingMore = false.obs;
  final searchError = RxnString();
  final searchHasMore = true.obs;
  final searchHistory = <String>[].obs;
  int _searchPage = 1;
  int _searchRequestId = 0;
  Timer? _debounce;

  /// Berita yang tampil berasal dari simpanan lokal, bukan dari server.
  final isShowingCache = false.obs;

  /// Kapan daftar berita terakhir berhasil diunduh.
  final lastUpdated = Rxn<DateTime>();

  // --- Bookmark, tema, preferensi baca ---
  final bookmarks = <NewsArticle>[].obs;
  final isDarkMode = false.obs;
  final readArticles = <String>{}.obs;
  final readerScale = 1.0.obs;

  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _restore();
    fetchHeadlines();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _newsService.dispose();
    super.onClose();
  }

  Future<SharedPreferences> get _storage async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<void> _restore() async {
    final prefs = await _storage;

    isDarkMode.value = prefs.getBool(StorageKeys.darkMode) ?? false;
    readerScale.value = prefs.getDouble(StorageKeys.readerScale) ?? 1.0;
    readArticles.addAll(prefs.getStringList(StorageKeys.readArticles) ?? []);
    searchHistory.assignAll(
      prefs.getStringList(StorageKeys.searchHistory) ?? [],
    );
    bookmarks.assignAll(
      (prefs.getStringList(StorageKeys.bookmarks) ?? []).map(
        (item) =>
            NewsArticle.fromJson(jsonDecode(item) as Map<String, dynamic>),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Beranda
  // ---------------------------------------------------------------------------

  /// Muat halaman pertama kategori yang sedang aktif.
  Future<void> fetchHeadlines() async {
    final requestId = ++_requestId;
    _page = 1;
    isLoading.value = true;
    errorMessage.value = null;

    // Tampilkan simpanan lokal lebih dulu supaya layar tidak kosong
    // selama menunggu jaringan.
    if (articles.isEmpty) await _loadCache(selectedCategory.value);
    if (requestId != _requestId) return;

    try {
      final response = await _newsService.getTopHeadlines(
        category: selectedCategory.value,
        page: _page,
      );
      if (requestId != _requestId) return;

      articles.assignAll(response.articles);
      hasMore.value = _canLoadMore(_page, response);
      isShowingCache.value = false;
      lastUpdated.value = DateTime.now();
      await _saveCache(selectedCategory.value, response.articles);
    } on NewsServiceException catch (e) {
      if (requestId != _requestId) return;
      // Masih ada simpanan lokal: pakai itu, jangan tunjukkan layar error.
      if (articles.isNotEmpty && isShowingCache.value) {
        hasMore.value = false;
      } else {
        articles.clear();
        errorMessage.value = e.message;
      }
    } finally {
      if (requestId == _requestId) isLoading.value = false;
    }
  }

  /// Dipakai pull-to-refresh: memuat ulang tanpa mengosongkan layar dulu.
  Future<void> refreshHeadlines() => fetchHeadlines();

  /// Muat halaman berikutnya saat pengguna scroll ke bawah.
  Future<void> loadMoreHeadlines() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;

    final requestId = _requestId;
    final nextPage = _page + 1;
    isLoadingMore.value = true;

    try {
      final response = await _newsService.getTopHeadlines(
        category: selectedCategory.value,
        page: nextPage,
      );
      if (requestId != _requestId) return;

      articles.addAll(response.articles);
      _page = nextPage;
      hasMore.value = _canLoadMore(nextPage, response);
    } on NewsServiceException catch (e) {
      if (requestId != _requestId) return;
      // Berita yang sudah tampil tetap dibiarkan; cukup hentikan pagination.
      hasMore.value = false;
      if (!e.isPagingLimit) {
        Get.snackbar(
          'Gagal memuat',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (requestId == _requestId) isLoadingMore.value = false;
    }
  }

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    articles.clear();
    fetchHeadlines();
  }

  bool _canLoadMore(int page, NewsResponse response) {
    if (response.articles.isEmpty) return false;
    final loaded = page * Constants.pageSize;
    return loaded < (response.totalResults ?? 0) &&
        loaded < Constants.maxResults;
  }

  /// Simpan sebagian berita terbaru supaya bisa dibaca tanpa koneksi.
  Future<void> _saveCache(String category, List<NewsArticle> items) async {
    if (items.isEmpty) return;
    final prefs = await _storage;
    await prefs.setString(
      '${StorageKeys.newsCachePrefix}$category',
      jsonEncode({
        'savedAt': DateTime.now().toIso8601String(),
        'articles': items
            .take(Constants.cachedPerCategory)
            .map((item) => item.toJson())
            .toList(),
      }),
    );
  }

  Future<void> _loadCache(String category) async {
    final prefs = await _storage;
    final raw = prefs.getString('${StorageKeys.newsCachePrefix}$category');
    if (raw == null) return;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final cached = (data['articles'] as List<dynamic>)
          .map((item) => NewsArticle.fromJson(item as Map<String, dynamic>))
          .toList();
      if (cached.isEmpty) return;

      articles.assignAll(cached);
      isShowingCache.value = true;
      hasMore.value = false;
      lastUpdated.value = DateTime.tryParse(data['savedAt'] ?? '');
    } catch (_) {
      // Format cache lama/rusak: abaikan, biar diisi ulang dari server.
      await prefs.remove('${StorageKeys.newsCachePrefix}$category');
    }
  }

  // ---------------------------------------------------------------------------
  // Riwayat baca & ukuran teks
  // ---------------------------------------------------------------------------

  bool isRead(NewsArticle article) => readArticles.contains(article.url);

  /// Dipanggil saat artikel dibuka; judul yang sudah dibaca ditampilkan redup.
  Future<void> markAsRead(NewsArticle article) async {
    final url = article.url;
    if (url == null || url.isEmpty || readArticles.contains(url)) return;

    readArticles.add(url);
    if (readArticles.length > Constants.maxReadHistory) {
      readArticles.remove(readArticles.first);
    }

    final prefs = await _storage;
    await prefs.setStringList(StorageKeys.readArticles, readArticles.toList());
  }

  /// Putar ukuran teks halaman baca: 90% -> 100% -> 115% -> 130% -> 90%.
  Future<void> cycleReaderScale() async {
    final scales = Constants.readerScales;
    final next = (scales.indexOf(readerScale.value) + 1) % scales.length;
    readerScale.value = scales[next];

    final prefs = await _storage;
    await prefs.setDouble(StorageKeys.readerScale, readerScale.value);
  }

  /// Berita lain di kategori yang sedang dibuka, untuk saran di akhir artikel.
  List<NewsArticle> relatedTo(NewsArticle article, {int limit = 3}) {
    return articles
        .where((item) => item.url != article.url)
        .take(limit)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Pencarian
  // ---------------------------------------------------------------------------

  /// Dipanggil tiap ketikan. Permintaan dikirim 500ms setelah berhenti mengetik
  /// supaya tidak menghabiskan kuota API.
  void onSearchChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();

    if (query.isEmpty) {
      _debounce = null;
      clearSearch();
      return;
    }

    _debounce = Timer(Constants.searchDebounce, () => search(query));
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _debounce?.cancel();
    final requestId = ++_searchRequestId;
    searchQuery.value = trimmed;
    _searchPage = 1;
    isSearchLoading.value = true;
    searchError.value = null;

    try {
      final response = await _newsService.searchNews(
        query: trimmed,
        page: _searchPage,
      );
      if (requestId != _searchRequestId) return;

      searchResults.assignAll(response.articles);
      searchHasMore.value = _canLoadMore(_searchPage, response);
      if (response.articles.isNotEmpty) _rememberSearch(trimmed);
    } on NewsServiceException catch (e) {
      if (requestId != _searchRequestId) return;
      searchResults.clear();
      searchError.value = e.message;
    } finally {
      if (requestId == _searchRequestId) isSearchLoading.value = false;
    }
  }

  Future<void> loadMoreSearchResults() async {
    if (isSearchLoading.value ||
        isSearchLoadingMore.value ||
        !searchHasMore.value ||
        searchQuery.value.isEmpty) {
      return;
    }

    final requestId = _searchRequestId;
    final nextPage = _searchPage + 1;
    isSearchLoadingMore.value = true;

    try {
      final response = await _newsService.searchNews(
        query: searchQuery.value,
        page: nextPage,
      );
      if (requestId != _searchRequestId) return;

      searchResults.addAll(response.articles);
      _searchPage = nextPage;
      searchHasMore.value = _canLoadMore(nextPage, response);
    } on NewsServiceException catch (_) {
      if (requestId != _searchRequestId) return;
      searchHasMore.value = false;
    } finally {
      if (requestId == _searchRequestId) isSearchLoadingMore.value = false;
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    _searchRequestId++;
    searchQuery.value = '';
    searchResults.clear();
    searchError.value = null;
    searchHasMore.value = true;
    isSearchLoading.value = false;
    isSearchLoadingMore.value = false;
  }

  Future<void> _rememberSearch(String query) async {
    searchHistory
      ..removeWhere((item) => item.toLowerCase() == query.toLowerCase())
      ..insert(0, query);
    if (searchHistory.length > Constants.maxSearchHistory) {
      searchHistory.removeRange(
        Constants.maxSearchHistory,
        searchHistory.length,
      );
    }
    await _persistSearchHistory();
  }

  Future<void> removeSearchHistory(String query) async {
    searchHistory.remove(query);
    await _persistSearchHistory();
  }

  Future<void> clearSearchHistory() async {
    searchHistory.clear();
    await _persistSearchHistory();
  }

  Future<void> _persistSearchHistory() async {
    final prefs = await _storage;
    await prefs.setStringList(
      StorageKeys.searchHistory,
      searchHistory.toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // Bookmark
  // ---------------------------------------------------------------------------

  bool isBookmarked(NewsArticle article) =>
      bookmarks.any((item) => item.url == article.url);

  /// Simpan atau hapus bookmark. Mengembalikan true kalau artikel jadi tersimpan.
  Future<bool> toggleBookmark(NewsArticle article) async {
    final saved = isBookmarked(article);
    if (saved) {
      bookmarks.removeWhere((item) => item.url == article.url);
    } else {
      bookmarks.insert(0, article);
    }

    final prefs = await _storage;
    await prefs.setStringList(
      StorageKeys.bookmarks,
      bookmarks.map((item) => jsonEncode(item.toJson())).toList(),
    );
    return !saved;
  }

  // ---------------------------------------------------------------------------
  // Tema
  // ---------------------------------------------------------------------------

  Future<void> toggleTheme() async {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    final prefs = await _storage;
    await prefs.setBool(StorageKeys.darkMode, isDarkMode.value);
  }
}
