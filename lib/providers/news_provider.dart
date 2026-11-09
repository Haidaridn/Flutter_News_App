import 'package:flutter/foundation.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';

enum NewsStatus { loading, success, error, empty }

/// Provider menyimpan data berita dan status yang dibutuhkan oleh UI.
class NewsProvider extends ChangeNotifier {
  NewsProvider({required this.newsService});

  final NewsService newsService;

  NewsStatus _status = NewsStatus.loading;
  List<Article> _articles = const <Article>[];
  String? _errorMessage;

  NewsStatus get status => _status;
  List<Article> get articles => _articles;
  String? get errorMessage => _errorMessage;

  Future<void> loadArticles() async {
    _status = NewsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // async/await menunggu NewsService selesai mengambil daftar berita.
      final fetchedArticles = await newsService.fetchArticles();
      _articles = List<Article>.unmodifiable(fetchedArticles);
      _status = _articles.isEmpty ? NewsStatus.empty : NewsStatus.success;
    } catch (_) {
      _articles = const <Article>[];
      _status = NewsStatus.error;
      _errorMessage = 'Berita gagal dimuat. Silakan coba lagi.';
    }

    notifyListeners();
  }
}
