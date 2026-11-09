import 'package:flutter/foundation.dart';
import 'package:news_app/models/article.dart';

/// Provider menyimpan bookmark hanya di memori selama aplikasi berjalan.
class BookmarkProvider extends ChangeNotifier {
  final List<Article> _bookmarkedArticles = <Article>[];

  List<Article> get bookmarkedArticles =>
      List<Article>.unmodifiable(_bookmarkedArticles);

  bool isBookmarked(Article article) {
    final articleKey = _createArticleKey(article);
    return _bookmarkedArticles.any(
      (savedArticle) => _createArticleKey(savedArticle) == articleKey,
    );
  }

  void toggleBookmark(Article article) {
    final articleKey = _createArticleKey(article);
    final previousCount = _bookmarkedArticles.length;

    _bookmarkedArticles.removeWhere(
      (savedArticle) => _createArticleKey(savedArticle) == articleKey,
    );

    if (_bookmarkedArticles.length == previousCount) {
      _bookmarkedArticles.add(article);
    }

    notifyListeners();
  }

  String _createArticleKey(Article article) {
    final url = article.url?.trim();
    if (url != null && url.isNotEmpty) {
      return url;
    }

    final publishedAt = article.publishedAt?.toIso8601String() ?? '';
    return '${article.title}|${article.sourceName ?? ''}|$publishedAt';
  }
}
