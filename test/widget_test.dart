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
        Article(title: 'Berita pertama', sourceName: 'Sumber Uji'),
      ],
    );

    await tester.pumpWidget(MyApp(newsService: service));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Berita Terkini'), findsOneWidget);
    expect(find.text('Berita pertama'), findsOneWidget);
    expect(find.text('Sumber Uji'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
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
