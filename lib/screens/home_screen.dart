import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/screens/bookmark_screen.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/news_filters.dart';
import 'package:news_app/widgets/state_views.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TeknoKini'),
        actions: [
          IconButton(
            tooltip: 'Favorit',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const BookmarkScreen()),
              );
            },
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        ],
      ),
      body: Consumer2<NewsProvider, BookmarkProvider>(
        builder: (context, newsProvider, bookmarkProvider, child) {
          return RefreshIndicator(
            onRefresh: newsProvider.loadArticles,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.pageMaxWidth,
                    ),
                    child: NewsFilters(
                      enabled: newsProvider.canFilter,
                      categories: newsProvider.categories,
                      selectedCategory: newsProvider.selectedCategory,
                      onSearchChanged: newsProvider.updateSearchQuery,
                      onCategorySelected: newsProvider.selectCategory,
                    ),
                  ),
                ),
                switch (newsProvider.status) {
                  NewsStatus.loading => const LoadingView(),
                  NewsStatus.error => ErrorView(
                    message:
                        newsProvider.errorMessage ??
                        'Terjadi kesalahan tidak dikenal.',
                    onRetry: newsProvider.loadArticles,
                  ),
                  NewsStatus.empty => EmptyView(
                    message: newsProvider.hasActiveFilters
                        ? 'Tidak ada berita teknologi sesuai pencarian atau topik.'
                        : 'Belum ada berita teknologi untuk ditampilkan.',
                  ),
                  NewsStatus.success => _ArticleFeed(
                    newsProvider: newsProvider,
                    bookmarkProvider: bookmarkProvider,
                  ),
                },
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BookmarkScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmarks_outlined),
            selectedIcon: Icon(Icons.bookmarks),
            label: 'Tersimpan',
          ),
        ],
      ),
    );
  }
}

class _ArticleFeed extends StatelessWidget {
  const _ArticleFeed({
    required this.newsProvider,
    required this.bookmarkProvider,
  });

  final NewsProvider newsProvider;
  final BookmarkProvider bookmarkProvider;

  @override
  Widget build(BuildContext context) {
    final articles = newsProvider.articles;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.pageMaxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.medium,
            AppSpacing.page,
            AppSpacing.extraLarge,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sorotan hari ini',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.medium),
              _card(context, articles.first, featured: true),
              if (articles.length > 1) ...[
                const SizedBox(height: AppSpacing.extraLarge),
                Text(
                  'Berita terbaru',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.medium),
                for (final article in articles.skip(1)) ...[
                  _card(context, article),
                  const SizedBox(height: AppSpacing.medium),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, Article article, {bool featured = false}) {
    return ArticleCard(
      article: article,
      featured: featured,
      isBookmarked: bookmarkProvider.isBookmarked(article),
      onBookmarkToggle: () => bookmarkProvider.toggleBookmark(article),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetailScreen(article: article),
          ),
        );
      },
    );
  }
}
