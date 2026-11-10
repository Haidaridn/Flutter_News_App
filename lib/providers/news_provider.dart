import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/services/news_exception.dart';
import 'package:news_app/services/news_service.dart';

enum NewsStatus { loading, success, error, empty }

/// Provider menyimpan data berita dan status yang dibutuhkan oleh UI.
class NewsProvider extends ChangeNotifier {
  NewsProvider({
    required this.newsService,
    this.searchDebounceDuration = const Duration(milliseconds: 500),
  });

  static const String allCategories = 'Semua Teknologi';
  static const List<String> availableCategories = <String>[
    allCategories,
    'AI',
    'Keamanan Siber',
    'Software',
    'Gadget',
    'Startup',
    'Robotika',
  ];

  final NewsService newsService;
  final Duration searchDebounceDuration;

  NewsStatus _status = NewsStatus.loading;
  List<Article> _articles = const <Article>[];
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = allCategories;
  Timer? _searchDebounce;
  int _requestVersion = 0;

  NewsStatus get status => _status;
  List<Article> get articles => _articles;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get canFilter => _status != NewsStatus.loading;
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty || _selectedCategory != allCategories;

  List<String> get categories => availableCategories;

  Future<void> loadArticles() async {
    _searchDebounce?.cancel();
    final requestVersion = ++_requestVersion;
    _status = NewsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // async/await menunggu NewsService selesai mengambil daftar berita.
      final fetchedArticles = await newsService.fetchArticles(
        query: _searchQuery.isEmpty ? null : _searchQuery,
        category: _selectedCategory == allCategories ? null : _selectedCategory,
      );
      if (requestVersion != _requestVersion) {
        return;
      }
      _articles = List<Article>.unmodifiable(fetchedArticles);
      _status = _articles.isEmpty ? NewsStatus.empty : NewsStatus.success;
    } on NewsException catch (error) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _articles = const <Article>[];
      _status = NewsStatus.error;
      _errorMessage = error.message;
    } on TimeoutException {
      if (requestVersion != _requestVersion) {
        return;
      }
      _articles = const <Article>[];
      _status = NewsStatus.error;
      _errorMessage = 'Waktu koneksi habis. Periksa internet lalu coba lagi.';
    } catch (_) {
      if (requestVersion != _requestVersion) {
        return;
      }
      _articles = const <Article>[];
      _status = NewsStatus.error;
      _errorMessage =
          'Berita gagal dimuat. Periksa koneksi lalu silakan coba lagi.';
    }

    notifyListeners();
  }

  void updateSearchQuery(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery == _searchQuery) {
      return;
    }

    _searchQuery = normalizedQuery;
    _searchDebounce?.cancel();
    // Provider menunda request agar API tidak dipanggil pada setiap ketikan.
    _searchDebounce = Timer(searchDebounceDuration, () {
      unawaited(loadArticles());
    });
    notifyListeners();
  }

  void selectCategory(String category) {
    if (!categories.contains(category) || category == _selectedCategory) {
      return;
    }

    _selectedCategory = category;
    _searchDebounce?.cancel();
    unawaited(loadArticles());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
