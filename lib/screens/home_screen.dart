import 'package:flutter/material.dart';
import 'package:news_app/providers/news_provider.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:news_app/widgets/state_views.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berita Terkini')),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          return switch (newsProvider.status) {
            NewsStatus.loading => const LoadingView(),
            NewsStatus.error => ErrorView(
              message:
                  newsProvider.errorMessage ??
                  'Terjadi kesalahan tidak dikenal.',
              onRetry: newsProvider.loadArticles,
            ),
            NewsStatus.empty => const EmptyView(),
            NewsStatus.success => RefreshIndicator(
              onRefresh: newsProvider.loadArticles,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.medium),
                itemCount: newsProvider.articles.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.medium),
                itemBuilder: (context, index) {
                  return ArticleCard(article: newsProvider.articles[index]);
                },
              ),
            ),
          };
        },
      ),
    );
  }
}
