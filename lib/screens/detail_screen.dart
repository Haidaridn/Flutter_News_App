import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Berita')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ArticleImage(
              imageUrl: article.urlToImage,
              height: AppSizes.detailImageHeight,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  _ArticleMetadata(article: article),
                  const SizedBox(height: AppSpacing.large),
                  Text(
                    article.description ?? 'Deskripsi artikel tidak tersedia.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.extraLarge),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: article.url == null
                          ? null
                          : () => _showLinkNotice(context),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Baca selengkapnya'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tautan artikel akan dibuka pada tahap integrasi API.'),
      ),
    );
  }
}

class _ArticleMetadata extends StatelessWidget {
  const _ArticleMetadata({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      article.sourceName ?? 'Sumber tidak diketahui',
      article.author ?? 'Penulis tidak diketahui',
      _formatDate(article.publishedAt),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in metadata) ...[
          Text(item, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.small),
        ],
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Tanggal tidak tersedia';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
