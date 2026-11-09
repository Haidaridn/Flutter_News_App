import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';

enum MockNewsResult { success, error, empty }

class MockNewsService implements NewsService {
  const MockNewsService({
    this.result = MockNewsResult.success,
    this.delay = const Duration(seconds: 1),
  });

  static const String _assetPath = 'assets/mock/articles.json';

  final MockNewsResult result;
  final Duration delay;

  @override
  Future<List<Article>> fetchArticles() async {
    // async/await meniru waktu tunggu saat mengambil data dari jaringan.
    await Future<void>.delayed(delay);

    switch (result) {
      case MockNewsResult.error:
        throw Exception('Simulasi gagal memuat berita.');
      case MockNewsResult.empty:
        return const <Article>[];
      case MockNewsResult.success:
        return _loadArticles();
    }
  }

  Future<List<Article>> _loadArticles() async {
    // Future ini membaca file JSON lokal seperti respons API pada tahap nanti.
    final jsonText = await rootBundle.loadString(_assetPath);
    final decodedJson = jsonDecode(jsonText);

    if (decodedJson is! Map<String, dynamic>) {
      throw const FormatException('Format respons berita tidak valid.');
    }

    final articleList = decodedJson['articles'];
    if (articleList is! List<dynamic>) {
      throw const FormatException('Daftar artikel tidak ditemukan.');
    }

    return articleList
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Format artikel tidak valid.');
          }

          return Article.fromJson(item);
        })
        .toList(growable: false);
  }
}
