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

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.medium),
            itemCount: articles.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.medium),
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleCard(
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
              );
            },
          );
        },
      ),
    );
  }
}
