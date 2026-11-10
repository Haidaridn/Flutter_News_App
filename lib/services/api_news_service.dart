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
  static const String _path = '/v2/everything';

  static const String _allTechnologyQuery =
      '(technology OR software OR cybersecurity OR robotics OR gadget OR startup OR "artificial intelligence")';
  static const Map<String, String> _topicQueries = <String, String>{
    'semua teknologi': _allTechnologyQuery,
    'ai':
        '("artificial intelligence" OR "machine learning" OR "generative AI" OR "large language model")',
    'keamanan siber':
        '(cybersecurity OR "cyber security" OR ransomware OR "data breach")',
    'software': '(software OR programming OR developer OR "open source")',
    'gadget': '(gadget OR smartphone OR laptop OR wearable)',
    'startup': '(startup OR "venture capital" OR founder)',
    'robotika': '(robotics OR robot OR automation OR drone)',
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

    final queryParameters = <String, String>{
      'q': _buildTechnologyQuery(query: query, topic: category),
      'searchIn': 'title,description',
      'language': 'en',
      'sortBy': 'publishedAt',
      'pageSize': '20',
    };

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

  String _buildTechnologyQuery({String? query, String? topic}) {
    final normalizedTopic = topic?.trim().toLowerCase();
    final topicQuery = _topicQueries[normalizedTopic] ?? _allTechnologyQuery;
    final normalizedQuery = query?.trim().replaceAll('"', '');
    if (normalizedQuery == null || normalizedQuery.isEmpty) {
      return topicQuery;
    }

    return '$topicQuery AND "$normalizedQuery"';
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
