import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/news_article.dart';
import '../models/news_response.dart';
import '../services/news_service.dart';
import '../utils/constants.dart';

/// State management berita: headlines per kategori, search, pagination,
/// bookmark, dan dark mode.
class NewsController extends GetxController {
  final NewsService _newsService;

  NewsController({required this._newsService});

  // --- State berita ---
  final articles = <NewsArticle>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = RxnString();
  final selectedCategory = Constants.categories.first.obs;
  final hasMore = true.obs;
  int _currentPage = 1;

  // Naik tiap request baru; respons dengan id lama diabaikan
  // (mis. user ganti kategori sebelum request sebelumnya selesai).
  int _requestId = 0;

  // --- State search ---
  final isSearching = false.obs;
  final searchQuery = ''.obs;
  final searchTextController = TextEditingController();
  Timer? _debounce;

  // --- State bookmark & tema ---
  final bookmarks = <NewsArticle>[].obs;
  final isDarkMode = false.obs;

  final scrollController = ScrollController();

  bool get isBookmarkMode => selectedCategory.value == Constants.bookmarksCategory;
  bool get isSearchMode => searchQuery.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _loadPreferences();
    fetchNews();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.dispose();
    searchTextController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  // ---------------------------------------------------------------------------
  // Berita
  // ---------------------------------------------------------------------------

  Future<NewsResponse> _request(int page) {
    if (isSearchMode) {
      return _newsService.searchNews(searchQuery.value, page: page);
    }
    return _newsService.getTopHeadlines(
      category: selectedCategory.value,
      page: page,
    );
  }

  /// Muat halaman pertama sesuai mode aktif (search atau kategori).
  Future<void> fetchNews() async {
    if (isBookmarkMode && !isSearchMode) return;

    final requestId = ++_requestId;
    _currentPage = 1;
    isLoading.value = true;
    isLoadingMore.value = false;
    errorMessage.value = null;
    articles.clear();

    try {
      final response = await _request(_currentPage);
      if (requestId != _requestId) return;
      articles.assignAll(response.articles);
      hasMore.value = Constants.pageSize < response.totalResults;
    } on NewsServiceException catch (e) {
      if (requestId != _requestId) return;
      errorMessage.value = e.message;
    } catch (e) {
      if (requestId != _requestId) return;
      errorMessage.value = 'Terjadi kesalahan tak terduga: $e';
    } finally {
      if (requestId == _requestId) isLoading.value = false;
    }
  }

  /// Muat halaman berikutnya dan tambahkan ke list.
  Future<void> loadMore() async {
    if (isBookmarkMode && !isSearchMode) return;
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    if (errorMessage.value != null) return;

    final requestId = _requestId;
    final nextPage = _currentPage + 1;
    isLoadingMore.value = true;

    try {
      final response = await _request(nextPage);
      if (requestId != _requestId) return;
      articles.addAll(response.articles);
      _currentPage = nextPage;
      hasMore.value = response.articles.isNotEmpty &&
          nextPage * Constants.pageSize < response.totalResults;
    } on NewsServiceException catch (e) {
      if (requestId != _requestId) return;
      // Error di halaman lanjutan (mis. batas 100 hasil paket gratis):
      // stop pagination, tetap tampilkan list yang sudah ada.
      hasMore.value = false;
      Get.snackbar('Gagal memuat lagi', e.message, snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      if (requestId != _requestId) return;
      hasMore.value = false;
    } finally {
      if (requestId == _requestId) isLoadingMore.value = false;
    }
  }

  void changeCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    if (isSearching.value) closeSearch(refresh: false);
    if (scrollController.hasClients) scrollController.jumpTo(0);

    if (isBookmarkMode) {
      // Batalkan request yang sedang jalan.
      _requestId++;
      isLoading.value = false;
      isLoadingMore.value = false;
      errorMessage.value = null;
      return;
    }
    fetchNews();
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  void openSearch() => isSearching.value = true;

  /// Dipanggil tiap ketikan; request baru dikirim 500ms setelah user berhenti mengetik.
  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = value.trim();
      if (query == searchQuery.value) return;
      searchQuery.value = query;
      fetchNews();
    });
  }

  /// Tutup search. [refresh] = muat ulang headlines kategori aktif
  /// kalau sebelumnya sedang menampilkan hasil pencarian.
  void closeSearch({bool refresh = true}) {
    _debounce?.cancel();
    isSearching.value = false;
    searchTextController.clear();
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
    if (refresh) fetchNews();
  }

  // ---------------------------------------------------------------------------
  // Bookmark
  // ---------------------------------------------------------------------------

  bool isBookmarked(NewsArticle article) {
    return bookmarks.any((a) => a.url == article.url);
  }

  Future<void> toggleBookmark(NewsArticle article) async {
    if (isBookmarked(article)) {
      bookmarks.removeWhere((a) => a.url == article.url);
    } else {
      bookmarks.add(article);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      StorageKeys.bookmarks,
      bookmarks.map((a) => jsonEncode(a.toJson())).toList(),
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(StorageKeys.isDarkMode) ?? false;

    final jsonList = prefs.getStringList(StorageKeys.bookmarks) ?? [];
    bookmarks.assignAll(
      jsonList.map((s) => NewsArticle.fromJson(jsonDecode(s) as Map<String, dynamic>)),
    );
  }

  // ---------------------------------------------------------------------------
  // Tema
  // ---------------------------------------------------------------------------

  Future<void> toggleTheme() async {
    isDarkMode.toggle();
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isDarkMode, isDarkMode.value);
  }
}
