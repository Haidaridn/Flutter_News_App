import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/theme/app_theme.dart';

void main() {
  testWidgets('Beranda menampilkan loading lalu daftar berita', (
    WidgetTester tester,
  ) async {
    final service = _FakeNewsService(
      articles: const <Article>[
        Article(
          title: 'Berita pertama',
          sourceName: 'Sumber Uji',
          author: 'Penulis Uji',
          description: 'Deskripsi berita uji.',
          url: 'https://example.com/berita-pertama',
        ),
      ],
    );

    await tester.pumpWidget(MyApp(newsService: service));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Berita Teknologi Terkini'), findsOneWidget);
    expect(find.text('Berita pertama'), findsOneWidget);
    expect(find.text('Sumber Uji'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.ensureVisible(find.text('Berita pertama'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Berita pertama'));
    await tester.pumpAndSettle();
    expect(find.text('Detail Berita'), findsOneWidget);
    expect(find.text('Penulis Uji'), findsOneWidget);
    expect(find.text('Deskripsi berita uji.'), findsOneWidget);
    expect(find.text('Baca selengkapnya'), findsOneWidget);
  });

  testWidgets('Beranda menampilkan hasil kosong', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(newsService: _FakeNewsService(articles: const <Article>[])),
    );

    await tester.pumpAndSettle();
    expect(
      find.text('Belum ada berita teknologi untuk ditampilkan.'),
      findsOneWidget,
    );
  });

  testWidgets('Beranda menampilkan error dan tombol coba lagi', (
    WidgetTester tester,
  ) async {
    final service = _FakeNewsService(error: Exception('Gagal'));
    await tester.pumpWidget(MyApp(newsService: service));

    await tester.pumpAndSettle();
    expect(
      find.text('Berita gagal dimuat. Periksa koneksi lalu silakan coba lagi.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);

    await tester.ensureVisible(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(service.callCount, 2);
  });

  testWidgets('Bookmark dari Beranda tampil dan dapat dihapus di Favorit', (
    WidgetTester tester,
  ) async {
    final service = _FakeNewsService(
      articles: const <Article>[
        Article(
          title: 'Berita untuk disimpan',
          url: 'https://example.com/berita-disimpan',
        ),
      ],
    );
    await tester.pumpWidget(MyApp(newsService: service));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Simpan ke favorit'));
    await tester.pump();
    expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);

    await tester.tap(find.byTooltip('Favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Favorit'), findsOneWidget);
    expect(find.text('Berita untuk disimpan'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus dari favorit'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada artikel favorit.'), findsOneWidget);
  });

  testWidgets('Pencarian dan topik menyaring daftar berita teknologi', (
    WidgetTester tester,
  ) async {
    final service = _FakeNewsService(
      articles: const <Article>[
        Article(title: 'Model AI Terbaru', category: 'AI'),
        Article(title: 'Robot Pelajar Menang', category: 'Robotika'),
      ],
    );
    await tester.pumpWidget(MyApp(newsService: service));
    await tester.pumpAndSettle();

    expect(find.text('Model AI Terbaru'), findsOneWidget);
    expect(find.text('Robot Pelajar Menang'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('news-search-field')), 'model');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Model AI Terbaru'), findsOneWidget);
    expect(find.text('Robot Pelajar Menang'), findsNothing);

    await tester.enterText(find.byKey(const Key('news-search-field')), 'xyz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak ada berita teknologi sesuai pencarian atau topik.'),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('news-search-field')), '');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    final roboticsChip = find.widgetWithText(ChoiceChip, 'Robotika');
    await tester.ensureVisible(roboticsChip);
    await tester.pumpAndSettle();
    await tester.tap(roboticsChip);
    await tester.pumpAndSettle();
    expect(find.text('Model AI Terbaru'), findsNothing);
    expect(find.text('Robot Pelajar Menang'), findsOneWidget);
  });

  for (final size in <Size>[const Size(320, 568), const Size(1200, 800)]) {
    testWidgets('Beranda dan Detail tanpa overflow pada $size', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MyApp(
          newsService: _FakeNewsService(
            articles: const <Article>[
              Article(title: 'Perkembangan AI untuk Pembelajaran'),
              Article(
                title: 'Keamanan Siber untuk Perangkat Sekolah',
                category: 'Keamanan Siber',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final headline = find.text('Perkembangan AI untuk Pembelajaran');
      if (size.width < AppSizes.narrowCardWidth) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      } else {
        await tester.ensureVisible(headline);
      }
      await tester.pumpAndSettle();
      await tester.tap(headline);
      await tester.pumpAndSettle();
      expect(find.text('Detail Berita'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

class _FakeNewsService implements NewsService {
  _FakeNewsService({this.articles = const <Article>[], this.error});

  final List<Article> articles;
  final Object? error;
  int callCount = 0;

  @override
  Future<List<Article>> fetchArticles({String? query, String? category}) async {
    callCount += 1;
    // Future memberi satu frame loading sebelum hasil uji dikembalikan.
    await Future<void>.delayed(Duration.zero);

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
