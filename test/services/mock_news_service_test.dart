import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/services/mock_news_service.dart';
import 'package:news_app/services/news_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockNewsService', () {
    test('memuat artikel saat hasil simulasi sukses', () async {
      final NewsService service = MockNewsService(delay: Duration.zero);

      // async/await menunggu service menyelesaikan pembacaan JSON lokal.
      final articles = await service.fetchArticles();

      expect(articles, hasLength(3));
      expect(
        articles.first.title,
        'Pelajar Indonesia Kembangkan Aplikasi Berita Ramah Pengguna',
      );
    });

    test('mengembalikan daftar kosong saat hasil simulasi kosong', () async {
      final NewsService service = MockNewsService(
        result: MockNewsResult.empty,
        delay: Duration.zero,
      );

      // async/await menunggu hasil kosong dari service.
      final articles = await service.fetchArticles();

      expect(articles, isEmpty);
    });

    test('melempar error saat hasil simulasi error', () async {
      final NewsService service = MockNewsService(
        result: MockNewsResult.error,
        delay: Duration.zero,
      );

      // expectLater menunggu Future selesai dengan error simulasi.
      await expectLater(service.fetchArticles(), throwsException);
    });

    test('memakai jeda bawaan satu detik', () {
      const service = MockNewsService();

      expect(service.delay, const Duration(seconds: 1));
    });

    test('menyaring artikel berdasarkan query dan kategori', () async {
      const service = MockNewsService(delay: Duration.zero);

      final articles = await service.fetchArticles(
        query: 'kompetisi',
        category: 'Olahraga',
      );

      expect(articles, hasLength(1));
      expect(articles.single.category, 'Olahraga');
    });
  });
}
