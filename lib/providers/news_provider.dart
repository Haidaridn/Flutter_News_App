import 'package:flutter/foundation.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_service.dart';

enum NewsStatus { loading, success, error, empty }

/// Provider menyimpan data berita dan status yang dibutuhkan oleh UI.
class NewsProvider extends ChangeNotifier {
  NewsProvider({required this.newsService});

  static const String allCategories = 'Semua';

  final NewsService newsService;

  NewsStatus _status = NewsStatus.loading;
  List<Article> _allArticles = const <Article>[];
  List<Article> _articles = const <Article>[];
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = allCategories;

  NewsStatus get status => _status;
  List<Article> get articles => _articles;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get canFilter =>
      _allArticles.isNotEmpty &&
      _status != NewsStatus.loading &&
      _status != NewsStatus.error;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedCategory != allCategories;

  List<String> get categories {
    final availableCategories =
        _allArticles
            .map((article) => article.category)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    return <String>[allCategories, ...availableCategories];
  }

  Future<void> loadArticles() async {
    _status = NewsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // async/await menunggu NewsService selesai mengambil daftar berita.
      final fetchedArticles = await newsService.fetchArticles();
      _allArticles = List<Article>.unmodifiable(fetchedArticles);
      if (!categories.contains(_selectedCategory)) {
        _selectedCategory = allCategories;
      }
      _applyFilters();
    } catch (_) {
      _allArticles = const <Article>[];
      _articles = const <Article>[];
      _status = NewsStatus.error;
      _errorMessage = 'Berita gagal dimuat. Silakan coba lagi.';
    }

    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(String category) {
    if (!categories.contains(category)) {
      return;
    }

    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final normalizedQuery = _searchQuery.toLowerCase();
    final filteredArticles = _allArticles
        .where((article) {
          final matchesCategory =
              _selectedCategory == allCategories ||
              article.category == _selectedCategory;
          final searchableText = <String>[
            article.title,
            article.sourceName ?? '',
            article.description ?? '',
          ].join(' ').toLowerCase();
          final matchesQuery =
              normalizedQuery.isEmpty ||
              searchableText.contains(normalizedQuery);
          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);

    _articles = List<Article>.unmodifiable(filteredArticles);
    _status = _articles.isEmpty ? NewsStatus.empty : NewsStatus.success;
  }
}
