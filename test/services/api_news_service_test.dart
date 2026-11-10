import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:news_app/services/api_news_service.dart';
import 'package:news_app/services/news_exception.dart';

void main() {
  const testApiKey = 'TEST_ONLY_NOT_A_REAL_KEY';

  group('ApiNewsService', () {
    test('menolak request jika API key kosong', () async {
      final service = ApiNewsService(
        client: MockClient((_) async {
          fail('HTTP tidak boleh dipanggil tanpa API key.');
        }),
        apiKey: '',
      );

      await expectLater(
        service.fetchArticles(),
        throwsA(
          isA<NewsException>().having(
            (error) => error.message,
            'message',
            contains('belum diisi'),
          ),
        ),
      );
    });

    test('mengirim header dan mem-parsing artikel NewsAPI', () async {
      final client = MockClient((request) async {
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'newsapi.org');
        expect(request.url.path, '/v2/everything');
        expect(request.url.queryParameters['pageSize'], '20');
        expect(request.url.queryParameters['searchIn'], 'title,description');
        expect(request.url.queryParameters['language'], 'en');
        expect(request.url.queryParameters['sortBy'], 'publishedAt');
        expect(
          request.url.queryParameters['q'],
          '("artificial intelligence" OR "machine learning" OR "generative AI" OR "large language model") AND "flutter"',
        );
        expect(request.url.queryParameters, isNot(contains('country')));
        expect(request.url.queryParameters, isNot(contains('category')));
        expect(request.headers['X-Api-Key'], testApiKey);

        return http.Response(
          jsonEncode(<String, Object?>{
            'status': 'ok',
            'articles': <Object?>[
              <String, Object?>{
                'source': <String, Object?>{'name': 'Sumber Uji'},
                'author': 'Penulis Uji',
                'title': 'Berita dari API',
                'description': null,
                'url': 'https://example.com/berita',
                'urlToImage': null,
                'publishedAt': '2026-11-10T01:00:00Z',
                'content': null,
              },
            ],
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      });
      final service = ApiNewsService(client: client, apiKey: testApiKey);

      // async/await menunggu respons palsu tanpa mengakses internet.
      final articles = await service.fetchArticles(
        query: 'flutter',
        category: 'AI',
      );

      expect(articles, hasLength(1));
      expect(articles.single.title, 'Berita dari API');
      expect(articles.single.sourceName, 'Sumber Uji');
      expect(articles.single.description, isNull);
      expect(articles.single.publishedAt, DateTime.utc(2026, 11, 10, 1));
    });

    test('menganggap articles null sebagai daftar kosong', () async {
      final service = ApiNewsService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(<String, Object?>{'status': 'ok', 'articles': null}),
            200,
          ),
        ),
        apiKey: testApiKey,
      );

      final articles = await service.fetchArticles();

      expect(articles, isEmpty);
    });

    for (final testCase in <({int statusCode, String messagePart})>[
      (statusCode: 400, messagePart: 'Parameter'),
      (statusCode: 401, messagePart: 'API key'),
      (statusCode: 429, messagePart: 'Batas permintaan'),
      (statusCode: 500, messagePart: 'Server berita'),
    ]) {
      test(
        'mengubah HTTP ${testCase.statusCode} menjadi pesan ramah',
        () async {
          final service = ApiNewsService(
            client: MockClient(
              (_) async => http.Response('{}', testCase.statusCode),
            ),
            apiKey: testApiKey,
          );

          await expectLater(
            service.fetchArticles(),
            throwsA(
              isA<NewsException>().having(
                (error) => error.message,
                'message',
                contains(testCase.messagePart),
              ),
            ),
          );
        },
      );
    }

    test('mengubah timeout menjadi pesan koneksi yang ramah', () async {
      final pendingResponse = Completer<http.Response>();
      final service = ApiNewsService(
        client: MockClient((_) => pendingResponse.future),
        apiKey: testApiKey,
        timeout: const Duration(milliseconds: 1),
      );

      await expectLater(
        service.fetchArticles(),
        throwsA(
          isA<NewsException>().having(
            (error) => error.message,
            'message',
            contains('Waktu koneksi habis'),
          ),
        ),
      );
    });

    test('mengubah kegagalan koneksi menjadi pesan yang ramah', () async {
      final service = ApiNewsService(
        client: MockClient(
          (_) async => throw http.ClientException('simulasi tanpa internet'),
        ),
        apiKey: testApiKey,
      );

      await expectLater(
        service.fetchArticles(),
        throwsA(
          isA<NewsException>().having(
            (error) => error.message,
            'message',
            contains('Tidak dapat terhubung ke internet'),
          ),
        ),
      );
    });
  });
}
