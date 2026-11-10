import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_exception.dart';
import 'package:news_app/services/news_service.dart';

class ApiNewsService implements NewsService {
  factory ApiNewsService({
    http.Client? client,
    String apiKey = _environmentApiKey,
    Duration timeout = const Duration(seconds: 10),
  }) {
    return ApiNewsService._(client ?? http.Client(), apiKey, timeout);
  }

  ApiNewsService._(this._client, this._apiKey, this.timeout);

  static const String _environmentApiKey = String.fromEnvironment(
    'NEWS_API_KEY',
  );
  static const String _host = 'newsapi.org';
  static const String _path = '/v2/top-headlines';

  static const Map<String, String> _categoryCodes = <String, String>{
    'bisnis': 'business',
    'business': 'business',
    'hiburan': 'entertainment',
    'entertainment': 'entertainment',
    'umum': 'general',
    'general': 'general',
    'kesehatan': 'health',
    'health': 'health',
    'sains': 'science',
    'science': 'science',
    'olahraga': 'sports',
    'sports': 'sports',
    'teknologi': 'technology',
    'technology': 'technology',
  };

  final http.Client _client;
  final String _apiKey;
  final Duration timeout;

  @override
  Future<List<Article>> fetchArticles({String? query, String? category}) async {
    // Future ini menyelesaikan permintaan NewsAPI secara asinkron.
    if (_apiKey.trim().isEmpty) {
      throw const NewsException(
        'API key NewsAPI belum diisi. Tambahkan key ke env.json lalu jalankan ulang aplikasi.',
      );
    }

    final queryParameters = <String, String>{'country': 'us', 'pageSize': '20'};
    final normalizedQuery = query?.trim();
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      queryParameters['q'] = normalizedQuery;
    }
    final categoryCode = _readCategoryCode(category);
    if (categoryCode != null) {
      queryParameters['category'] = categoryCode;
    }

    final uri = Uri.https(_host, _path, queryParameters);

    try {
      // await menunggu respons HTTP tanpa menghentikan antarmuka aplikasi.
      final response = await _client
          .get(uri, headers: <String, String>{'X-Api-Key': _apiKey})
          .timeout(timeout);

      if (response.statusCode != 200) {
        throw _createHttpException(response.statusCode);
      }

      // JSON respons diubah menjadi model Article yang aman terhadap nilai null.
      final decodedJson = jsonDecode(response.body);
      if (decodedJson is! Map<String, dynamic>) {
        throw const NewsException('Format respons berita tidak valid.');
      }

      final articleList = decodedJson['articles'];
      if (articleList == null) {
        return const <Article>[];
      }
      if (articleList is! List<dynamic>) {
        throw const NewsException('Daftar artikel pada respons tidak valid.');
      }

      return articleList
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const NewsException(
                'Format artikel pada respons tidak valid.',
              );
            }

            // fromJson memetakan setiap objek NewsAPI menjadi Article.
            return Article.fromJson(item);
          })
          .toList(growable: false);
    } on NewsException {
      rethrow;
    } on TimeoutException {
      throw const NewsException(
        'Waktu koneksi habis. Periksa internet lalu coba lagi.',
      );
    } on http.ClientException {
      throw const NewsException(
        'Tidak dapat terhubung ke internet. Periksa koneksi lalu coba lagi.',
      );
    } on FormatException {
      throw const NewsException('Data berita yang diterima tidak valid.');
    }
  }

  String? _readCategoryCode(String? category) {
    final normalizedCategory = category?.trim().toLowerCase();
    if (normalizedCategory == null || normalizedCategory.isEmpty) {
      return null;
    }
    return _categoryCodes[normalizedCategory];
  }

  NewsException _createHttpException(int statusCode) {
    return switch (statusCode) {
      400 => const NewsException('Parameter permintaan berita tidak valid.'),
      401 => const NewsException(
        'API key NewsAPI salah, belum diisi, atau tidak terkirim.',
      ),
      429 => const NewsException(
        'Batas permintaan NewsAPI tercapai. Silakan coba lagi nanti.',
      ),
      >= 500 => const NewsException(
        'Server berita sedang bermasalah. Silakan coba lagi nanti.',
      ),
      _ => const NewsException('Permintaan berita gagal. Silakan coba lagi.'),
    };
  }
}
