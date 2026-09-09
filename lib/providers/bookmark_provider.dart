import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class BookmarkProvider extends ChangeNotifier {
  static const String _storageKey = 'bookmarked_articles';

  List<Article> _bookmarks = [];
  bool _isLoaded = false;

  List<Article> get bookmarks => _bookmarks;
  bool get isLoaded => _isLoaded;

  bool isBookmarked(String url) {
    return _bookmarks.any((article) => article.url == url);
  }

  /// Muat bookmark tersimpan dari shared_preferences.
  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    _bookmarks = jsonList
        .map((jsonStr) => Article.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>))
        .toList();
    _isLoaded = true;
    notifyListeners();
  }

  /// Tambah/hapus bookmark tergantung status saat ini.
  Future<void> toggleBookmark(Article article) async {
    if (isBookmarked(article.url)) {
      _bookmarks = _bookmarks.where((a) => a.url != article.url).toList();
    } else {
      _bookmarks = [..._bookmarks, article];
    }
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _bookmarks.map((a) => jsonEncode(a.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
}
