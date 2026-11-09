import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Article.fromJson', () {
    test('memetakan file JSON contoh berformat NewsAPI', () async {
      // async/await menunggu file aset selesai dimuat sebelum JSON diuji.
      final jsonText = await rootBundle.loadString('assets/mock/articles.json');
      final response = jsonDecode(jsonText) as Map<String, dynamic>;
      final articleList = response['articles'] as List<dynamic>;
      final articles = articleList
          .map((item) => Article.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(response['status'], 'ok');
      expect(response['totalResults'], 3);
      expect(articles, hasLength(3));
      expect(
        articles.first.title,
        'Pelajar Indonesia Kembangkan Aplikasi Berita Ramah Pengguna',
      );
      expect(articles.first.sourceName, 'Kabar Nusantara');
      expect(articles.first.author, 'Alya Putri');
      expect(articles.first.category, 'Teknologi');
      expect(
        articles.first.publishedAt,
        DateTime.parse('2026-11-09T02:30:00Z'),
      );
    });

    test('menerima field opsional yang null atau kosong', () async {
      // async/await menunggu aset yang sama untuk menguji nilai kosong.
      final jsonText = await rootBundle.loadString('assets/mock/articles.json');
      final response = jsonDecode(jsonText) as Map<String, dynamic>;
      final articleList = response['articles'] as List<dynamic>;

      final articleWithNulls = Article.fromJson(
        articleList[1] as Map<String, dynamic>,
      );
      final articleWithEmptyImage = Article.fromJson(
        articleList[2] as Map<String, dynamic>,
      );

      expect(articleWithNulls.author, isNull);
      expect(articleWithNulls.description, isNull);
      expect(articleWithNulls.urlToImage, isNull);
      expect(articleWithNulls.content, isNull);
      expect(articleWithEmptyImage.sourceName, isNull);
      expect(articleWithEmptyImage.url, isNull);
      expect(articleWithEmptyImage.urlToImage, isNull);
      expect(articleWithEmptyImage.publishedAt, isNull);
    });

    test('mengubah tanggal tidak valid menjadi null', () {
      final article = Article.fromJson({
        'title': 'Contoh artikel',
        'publishedAt': 'tanggal-tidak-valid',
      });

      expect(article.publishedAt, isNull);
    });

    test('menolak artikel tanpa judul', () {
      expect(
        () => Article.fromJson({'title': null}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
