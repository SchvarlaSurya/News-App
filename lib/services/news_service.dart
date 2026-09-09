import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/article.dart';
import '../utils/constants.dart';

/// Exception khusus untuk error yang berasal dari NewsService.
class NewsServiceException implements Exception {
  final String message;

  NewsServiceException(this.message);

  @override
  String toString() => message;
}

class NewsService {
  final http.Client _client;
  static const Duration _timeoutDuration = Duration(seconds: 10);

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  /// Ambil berita utama (top headlines) berdasarkan kategori.
  Future<List<Article>> getTopHeadlines({
    String category = 'general',
    int page = 1,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/top-headlines').replace(
      queryParameters: {
        'country': 'us',
        'category': category,
        'page': page.toString(),
        'apiKey': ApiConstants.newsApiKey,
      },
    );

    return _fetchArticles(uri);
  }

  /// Cari berita berdasarkan kata kunci.
  Future<List<Article>> searchNews(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      throw NewsServiceException('Kata kunci pencarian tidak boleh kosong.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/everything').replace(
      queryParameters: {
        'q': query,
        'page': page.toString(),
        'apiKey': ApiConstants.newsApiKey,
      },
    );

    return _fetchArticles(uri);
  }

  Future<List<Article>> _fetchArticles(Uri uri) async {
    late final http.Response response;

    try {
      response = await _client.get(uri).timeout(_timeoutDuration);
    } on TimeoutException {
      throw NewsServiceException(
        'Waktu koneksi habis. Periksa koneksi internet Anda dan coba lagi.',
      );
    } on http.ClientException catch (e) {
      throw NewsServiceException('Gagal terhubung ke server: ${e.message}');
    } catch (e) {
      throw NewsServiceException('Terjadi kesalahan saat mengambil data: $e');
    }

    if (response.body.isEmpty) {
      throw NewsServiceException(
        'Server mengembalikan respons kosong. Coba lagi nanti.',
      );
    }

    late final Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw NewsServiceException(
        'Gagal membaca data dari server (format tidak valid).',
      );
    }

    if (response.statusCode != 200) {
      final message = data['message'] ?? 'Kesalahan tidak diketahui.';
      throw NewsServiceException(
        'Gagal mengambil berita (kode ${response.statusCode}): $message',
      );
    }

    final articlesJson = data['articles'] as List<dynamic>?;
    if (articlesJson == null) {
      throw NewsServiceException(
        'Data berita tidak ditemukan pada respons server.',
      );
    }

    return articlesJson
        .map((json) => Article.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  void dispose() {
    _client.close();
  }
}
