import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';

void main() {
  const article = Article(
    title: 'Berita favorit',
    url: 'https://example.com/berita-favorit',
  );

  group('BookmarkProvider', () {
    test('menambah dan menghapus bookmark di memori', () {
      final provider = BookmarkProvider();
      addTearDown(provider.dispose);

      provider.toggleBookmark(article);

      expect(provider.isBookmarked(article), isTrue);
      expect(provider.bookmarkedArticles, const <Article>[article]);

      provider.toggleBookmark(article);

      expect(provider.isBookmarked(article), isFalse);
      expect(provider.bookmarkedArticles, isEmpty);
    });

    test('mengenali artikel baru dengan URL yang sama', () {
      final provider = BookmarkProvider();
      addTearDown(provider.dispose);
      const reloadedArticle = Article(
        title: 'Judul dapat berubah',
        url: 'https://example.com/berita-favorit',
      );

      provider.toggleBookmark(article);

      expect(provider.isBookmarked(reloadedArticle), isTrue);
      provider.toggleBookmark(reloadedArticle);
      expect(provider.bookmarkedArticles, isEmpty);
    });

    test('daftar bookmark tidak dapat diubah dari luar Provider', () {
      final provider = BookmarkProvider();
      addTearDown(provider.dispose);
      provider.toggleBookmark(article);

      expect(
        () => provider.bookmarkedArticles.add(
          const Article(title: 'Artikel lain'),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
