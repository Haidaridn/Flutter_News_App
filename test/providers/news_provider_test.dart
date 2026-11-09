import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/news_provider.dart';
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

    test(
      'memakai status error dan pesan Indonesia saat service gagal',
      () async {
        final provider = NewsProvider(
          newsService: _FakeNewsService(error: Exception('Gagal')),
        );
        addTearDown(provider.dispose);

        await provider.loadArticles();

        expect(provider.status, NewsStatus.error);
        expect(provider.articles, isEmpty);
        expect(
          provider.errorMessage,
          'Berita gagal dimuat. Silakan coba lagi.',
        );
      },
    );
  });
}

class _ControlledNewsService implements NewsService {
  _ControlledNewsService(this.completer);

  final Completer<List<Article>> completer;

  @override
  Future<List<Article>> fetchArticles() => completer.future;
}

class _FakeNewsService implements NewsService {
  _FakeNewsService({this.articles = const <Article>[], this.error});

  final List<Article> articles;
  final Object? error;

  @override
  Future<List<Article>> fetchArticles() async {
    if (error != null) {
      throw error!;
    }

    return articles;
  }
}
