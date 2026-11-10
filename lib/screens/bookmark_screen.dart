import 'package:flutter/material.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/screens/detail_screen.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/state_views.dart';
import 'package:provider/provider.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorit')),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, child) {
          final articles = bookmarkProvider.bookmarkedArticles;

          if (articles.isEmpty) {
            return const EmptyView(message: 'Belum ada artikel favorit.');
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSizes.pageMaxWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.medium,
                  AppSpacing.page,
                  AppSpacing.extraLarge,
                ),
                children: [
                  Text(
                    'Artikel tersimpan',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    'Baca kembali berita pilihanmu kapan saja selama aplikasi terbuka.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.large),
                  for (final article in articles) ...[
                    ArticleCard(
                      article: article,
                      isBookmarked: true,
                      onBookmarkToggle: () {
                        bookmarkProvider.toggleBookmark(article);
                      },
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DetailScreen(article: article),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.medium),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) Navigator.of(context).pop();
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
