import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Detail menampilkan seluruh informasi artikel', (
    WidgetTester tester,
  ) async {
    final article = Article(
      title: 'Judul berita lengkap',
      sourceName: 'Sumber Berita',
      author: 'Penulis Berita',
      description: 'Deskripsi lengkap berita.',
      url: 'https://example.com/berita',
      publishedAt: DateTime.utc(2026, 11, 9),
    );

    await tester.pumpWidget(_buildDetailApp(article));

    expect(find.text('Detail Berita'), findsOneWidget);
    expect(find.text('Judul berita lengkap'), findsOneWidget);
    expect(find.text('Sumber Berita'), findsOneWidget);
    expect(find.text('Penulis Berita'), findsOneWidget);
    expect(find.text('09/11/2026'), findsOneWidget);
    expect(find.text('Deskripsi lengkap berita.'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);

    expect(find.byTooltip('Simpan ke favorit'), findsOneWidget);
    await tester.tap(find.byTooltip('Simpan ke favorit'));
    await tester.pump();
    expect(find.byTooltip('Hapus dari favorit'), findsOneWidget);

    await tester.tap(find.text('Baca selengkapnya'));
    await tester.pump();
    expect(
      find.text('Tautan artikel akan dibuka pada tahap integrasi API.'),
      findsOneWidget,
    );
  });

  testWidgets('Detail menangani field artikel yang kosong', (
    WidgetTester tester,
  ) async {
    const article = Article(title: 'Judul tetap tersedia');

    await tester.pumpWidget(_buildDetailApp(article));

    expect(find.text('Sumber tidak diketahui'), findsOneWidget);
    expect(find.text('Penulis tidak diketahui'), findsOneWidget);
    expect(find.text('Tanggal tidak tersedia'), findsOneWidget);
    expect(find.text('Deskripsi artikel tidak tersedia.'), findsOneWidget);

    final readMoreButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Baca selengkapnya'),
    );
    expect(readMoreButton.onPressed, isNull);
  });
}

Widget _buildDetailApp(Article article) {
  return ChangeNotifierProvider(
    create: (_) => BookmarkProvider(),
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: DetailScreen(article: article),
    ),
  );
}
