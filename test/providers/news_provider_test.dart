import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/services/news_exception.dart';
import 'package:news_app/services/news_service.dart';

void main() {
  const article = Article(title: 'Berita uji');

  group('NewsProvider', () {
    test('berpindah dari loading ke sukses', () async {
      final completer = Completer<List<Article>>();
      final provider = NewsProvider(
        newsService: _ControlledNewsService(completer),
      );
      addTearDown(provider.dispose);

      final loadFuture = provider.loadArticles();
      expect(provider.status, NewsStatus.loading);

      completer.complete(const <Article>[article]);
      // async/await menunggu proses pemuatan provider selesai.
      await loadFuture;

      expect(provider.status, NewsStatus.success);
      expect(provider.articles, const <Article>[article]);
      expect(provider.errorMessage, isNull);
    });

    test('memakai status kosong saat service tidak memiliki artikel', () async {
      final provider = NewsProvider(
        newsService: _FakeNewsService(articles: const <Article>[]),
      );
      addTearDown(provider.dispose);

      await provider.loadArticles();

      expect(provider.status, NewsStatus.empty);
      expect(provider.articles, isEmpty);
    });

    test('meneruskan pesan NewsException ke state error', () async {
      final provider = NewsProvider(
        newsService: _FakeNewsService(
          error: const NewsException('API key NewsAPI belum diisi.'),
        ),
      );
      addTearDown(provider.dispose);

      await provider.loadArticles();

      expect(provider.status, NewsStatus.error);
      expect(provider.articles, isEmpty);
      expect(provider.errorMessage, 'API key NewsAPI belum diisi.');
    });

    test('mengubah error umum menjadi pesan koneksi yang ramah', () async {
      final provider = NewsProvider(
        newsService: _FakeNewsService(error: Exception('Gagal')),
      );
      addTearDown(provider.dispose);

      await provider.loadArticles();

      expect(provider.status, NewsStatus.error);
      expect(
        provider.errorMessage,
        'Berita gagal dimuat. Periksa koneksi lalu silakan coba lagi.',
      );
    });

    test('menyaring artikel berdasarkan pencarian dan topik', () async {
      const aiArticle = Article(
        title: 'AI untuk Belajar Flutter',
        sourceName: 'Tekno Hari Ini',
        category: 'AI',
      );
      const roboticsArticle = Article(
        title: 'Robot Pelajar',
        sourceName: 'Laboratorium Sekolah',
        category: 'Robotika',
      );
      final provider = NewsProvider(
        newsService: _FakeNewsService(
          articles: const <Article>[aiArticle, roboticsArticle],
        ),
        searchDebounceDuration: Duration.zero,
      );
      addTearDown(provider.dispose);

      await provider.loadArticles();
      expect(provider.categories, NewsProvider.availableCategories);

      provider.updateSearchQuery('flutter');
      await Future<void>.delayed(Duration.zero);
      expect(provider.articles, const <Article>[aiArticle]);
      expect(provider.status, NewsStatus.success);

      provider.updateSearchQuery('tidak ditemukan');
      await Future<void>.delayed(Duration.zero);
      expect(provider.articles, isEmpty);
      expect(provider.status, NewsStatus.empty);

      provider.updateSearchQuery('');
      await Future<void>.delayed(Duration.zero);
      provider.selectCategory('Robotika');
      await Future<void>.delayed(Duration.zero);
      expect(provider.articles, const <Article>[roboticsArticle]);
      expect(provider.selectedCategory, 'Robotika');
    });
  });
}

class _ControlledNewsService implements NewsService {
  _ControlledNewsService(this.completer);

  final Completer<List<Article>> completer;

  @override
  Future<List<Article>> fetchArticles({String? query, String? category}) =>
      completer.future;
}

class _FakeNewsService implements NewsService {
  _FakeNewsService({this.articles = const <Article>[], this.error});

  final List<Article> articles;
  final Object? error;

  @override
  Future<List<Article>> fetchArticles({String? query, String? category}) async {
    if (error != null) {
      throw error!;
    }

    final normalizedQuery = query?.toLowerCase() ?? '';
    final normalizedCategory = category?.toLowerCase() ?? '';
    return articles
        .where((article) {
          final matchesQuery =
              normalizedQuery.isEmpty ||
              article.title.toLowerCase().contains(normalizedQuery);
          final matchesCategory =
              normalizedCategory.isEmpty ||
              article.category?.toLowerCase() == normalizedCategory;
          return matchesQuery && matchesCategory;
        })
        .toList(growable: false);
  }
}
