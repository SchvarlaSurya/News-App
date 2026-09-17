import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/news_response.dart';
import '../utils/constants.dart';

/// Exception khusus untuk error yang berasal dari NewsService.
class NewsServiceException implements Exception {
  final String message;

  NewsServiceException(this.message);

  @override
  String toString() => message;
}

/// Panggilan REST API ke NewsAPI.org.
class NewsService {
  final http.Client _client;

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  /// Ambil berita utama (top headlines) berdasarkan kategori.
  Future<NewsResponse> getTopHeadlines({
    String category = 'general',
    int page = 1,
  }) {
    return _get(Constants.topHeadlines, {
      'country': Constants.defaultCountry,
      'category': category,
    }, page);
  }

  /// Cari berita berdasarkan kata kunci.
  Future<NewsResponse> searchNews(String query, {int page = 1}) async {
    if (query.trim().isEmpty) {
      throw NewsServiceException('Kata kunci pencarian tidak boleh kosong.');
    }

    return _get(Constants.everything, {
      'q': query.trim(),
      'sortBy': 'publishedAt',
    }, page);
  }

  Future<NewsResponse> _get(
    String endpoint,
    Map<String, String> params,
    int page,
  ) async {
    if (Constants.apiKey.isEmpty) {
      throw NewsServiceException(
        'API key belum diatur. Isi API_KEY di file .env lalu restart aplikasi.',
      );
    }

    final uri = Uri.parse('${Constants.baseUrl}$endpoint').replace(
      queryParameters: {
        ...params,
        'page': page.toString(),
        'pageSize': Constants.pageSize.toString(),
        'apiKey': Constants.apiKey,
      },
    );

    late final http.Response response;
    try {
      response = await _client.get(uri).timeout(Constants.timeout);
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

    // Saat error, NewsAPI mengirim {status: 'error', code, message}.
    if (response.statusCode != 200 || data['status'] != 'ok') {
      throw NewsServiceException(
        'Gagal mengambil berita (kode ${response.statusCode}): '
        '${data['message'] ?? 'Kesalahan tidak diketahui.'}',
      );
    }

    final result = NewsResponse.fromJson(data);
    return NewsResponse(
      status: result.status,
      totalResults: result.totalResults,
      // Buang artikel tanpa URL (dipakai sebagai id bookmark) & artikel
      // yang sudah dihapus NewsAPI (judulnya "[Removed]").
      articles: result.articles
          .where((a) => a.url != null && a.url!.isNotEmpty && a.title != '[Removed]')
          .toList(),
    );
  }

  void dispose() {
    _client.close();
  }
}
