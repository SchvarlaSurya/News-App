import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:news_app/models/news_response.dart';
import 'package:news_app/utils/constants.dart';

/// Error dari NewsService. [message] sudah siap ditampilkan ke pengguna,
/// [isPagingLimit] menandai batas 100 hasil pada paket gratis NewsAPI.
class NewsServiceException implements Exception {
  final String message;
  final bool isPagingLimit;

  NewsServiceException(this.message, {this.isPagingLimit = false});

  @override
  String toString() => message;
}

class NewsService {
  final http.Client _client;

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  /// Berita utama berdasarkan negara & kategori.
  Future<NewsResponse> getTopHeadlines({
    String country = Constants.defaultCountry,
    String? category,
    int page = 1,
    int pageSize = Constants.pageSize,
  }) {
    return _get(Constants.topHeadlines, {
      'country': country,
      if (category != null && category.isNotEmpty) 'category': category,
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  /// Pencarian bebas lewat endpoint /everything.
  Future<NewsResponse> searchNews({
    required String query,
    int page = 1,
    int pageSize = Constants.pageSize,
    String sortBy = 'publishedAt',
  }) {
    return _get(Constants.everything, {
      'q': query.trim(),
      'sortBy': sortBy,
      'language': 'en',
      'page': '$page',
      'pageSize': '$pageSize',
    });
  }

  Future<NewsResponse> _get(
    String endpoint,
    Map<String, String> queryParams,
  ) async {
    if (Constants.apiKey.isEmpty) {
      throw NewsServiceException(
        'API key belum diatur. Isi API_KEY di file .env, lalu jalankan ulang aplikasi.',
      );
    }

    final uri = Uri.parse(
      '${Constants.baseUrl}$endpoint',
    ).replace(queryParameters: {...queryParams, 'apiKey': Constants.apiKey});

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(Constants.requestTimeout);
    } on TimeoutException {
      throw NewsServiceException(
        'Server tidak merespons. Coba lagi sebentar lagi.',
      );
    } on SocketException {
      throw NewsServiceException(
        'Tidak ada koneksi internet. Nyalakan data atau Wi-Fi, lalu coba lagi.',
      );
    } on http.ClientException {
      throw NewsServiceException(
        'Gagal terhubung ke server berita. Periksa koneksi internet Anda.',
      );
    }

    final Map<String, dynamic> data;
    try {
      data = json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw NewsServiceException('Data dari server tidak bisa dibaca.');
    }

    if (response.statusCode != 200 || data['status'] != 'ok') {
      throw _errorFor(response.statusCode, data);
    }

    final result = NewsResponse.fromJson(data);
    return NewsResponse(
      status: result.status,
      totalResults: result.totalResults,
      articles: result.articles.where((a) => a.isUsable).toList(),
    );
  }

  NewsServiceException _errorFor(int statusCode, Map<String, dynamic> data) {
    final code = data['code'];
    switch (statusCode) {
      case 401:
        return NewsServiceException(
          'API key ditolak server. Periksa API_KEY di file .env.',
        );
      case 429:
        return NewsServiceException(
          'Kuota permintaan hari ini habis. Coba lagi besok.',
        );
      case 426:
        return NewsServiceException(
          'Sudah sampai batas ${Constants.maxResults} berita untuk paket gratis NewsAPI.',
          isPagingLimit: true,
        );
      default:
        if (code == 'maximumResultsReached') {
          return NewsServiceException(
            'Sudah sampai batas ${Constants.maxResults} berita untuk paket gratis NewsAPI.',
            isPagingLimit: true,
          );
        }
        return NewsServiceException(
          data['message']?.toString() ??
              'Berita gagal dimuat (kode $statusCode).',
        );
    }
  }

  void dispose() => _client.close();
}
