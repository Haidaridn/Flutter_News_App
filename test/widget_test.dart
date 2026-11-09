import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/main.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';

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
    expect(find.text('Berita Terkini'), findsOneWidget);
    expect(find.text('Berita pertama'), findsOneWidget);
    expect(find.text('Sumber Uji'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

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
    expect(find.text('Belum ada berita untuk ditampilkan.'), findsOneWidget);
  });

  testWidgets('Beranda menampilkan error dan tombol coba lagi', (
    WidgetTester tester,
  ) async {
    final service = _FakeNewsService(error: Exception('Gagal'));
    await tester.pumpWidget(MyApp(newsService: service));

    await tester.pumpAndSettle();
    expect(
      find.text('Berita gagal dimuat. Silakan coba lagi.'),
      findsOneWidget,
    );
    expect(find.text('Coba lagi'), findsOneWidget);

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

  testWidgets('Pencarian dan kategori menyaring daftar berita', (
    WidgetTester tester,
  ) async {
    final service = _FakeNewsService(
      articles: const <Article>[
        Article(title: 'Pasar Digital Tumbuh', category: 'Bisnis'),
        Article(title: 'Tim Pelajar Menang', category: 'Olahraga'),
      ],
    );
    await tester.pumpWidget(MyApp(newsService: service));
    await tester.pumpAndSettle();

    expect(find.text('Pasar Digital Tumbuh'), findsOneWidget);
    expect(find.text('Tim Pelajar Menang'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('news-search-field')), 'pasar');
    await tester.pump();
    expect(find.text('Pasar Digital Tumbuh'), findsOneWidget);
    expect(find.text('Tim Pelajar Menang'), findsNothing);

    await tester.enterText(find.byKey(const Key('news-search-field')), 'xyz');
    await tester.pump();
    expect(
      find.text('Tidak ada berita sesuai pencarian atau kategori.'),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('news-search-field')), '');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Olahraga'));
    await tester.pump();
    expect(find.text('Pasar Digital Tumbuh'), findsNothing);
    expect(find.text('Tim Pelajar Menang'), findsOneWidget);
  });
}

class _FakeNewsService implements NewsService {
  _FakeNewsService({this.articles = const <Article>[], this.error});

  final List<Article> articles;
  final Object? error;
  int callCount = 0;

  @override
  Future<List<Article>> fetchArticles() async {
    callCount += 1;
    // Future memberi satu frame loading sebelum hasil uji dikembalikan.
    await Future<void>.delayed(Duration.zero);

    if (error != null) {
      throw error!;
    }

    return articles;
  }
}
