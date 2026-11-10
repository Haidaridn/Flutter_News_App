import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/providers/bookmark_provider.dart';
import 'package:news_app/theme/app_theme.dart';
import 'package:news_app/widgets/article_card.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

typedef ArticleLauncher = Future<bool> Function(Uri uri);

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.article,
    this.articleLauncher = _launchArticleExternally,
  });

  final Article article;
  final ArticleLauncher articleLauncher;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              final isBookmarked = bookmarkProvider.isBookmarked(article);
              return IconButton(
                onPressed: () => bookmarkProvider.toggleBookmark(article),
                tooltip: isBookmarked
                    ? 'Hapus dari favorit'
                    : 'Simpan ke favorit',
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.detailMaxWidth),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.medium,
              AppSpacing.page,
              AppSpacing.extraLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  child: ArticleImage(
                    imageUrl: article.urlToImage,
                    height: AppSizes.detailImageHeight,
                  ),
                ),
                const SizedBox(height: AppSpacing.large),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ArticleCategoryBadge(category: article.category),
                ),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.large),
                _ArticleMetadata(article: article),
                const SizedBox(height: AppSpacing.large),
                const Divider(),
                const SizedBox(height: AppSpacing.medium),
                Text(
                  article.description ?? 'Deskripsi artikel tidak tersedia.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (article.content != null &&
                    article.content!.trim().isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.medium),
                  Text(
                    article.content!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: AppSpacing.extraLarge),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openArticle(context),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Baca selengkapnya'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openArticle(BuildContext context) async {
    final uri = _readArticleUri(article.url);
    if (uri == null) {
      _showMessage(context, 'Tautan artikel tidak tersedia atau tidak valid.');
      return;
    }

    try {
      // async/await menunggu aplikasi eksternal membuka tautan artikel.
      final opened = await articleLauncher(uri);
      if (!context.mounted) {
        return;
      }
      if (!opened) {
        _showMessage(context, 'Tautan artikel gagal dibuka.');
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showMessage(context, 'Tautan artikel gagal dibuka.');
    }
  }

  Uri? _readArticleUri(String? url) {
    final uri = url == null ? null : Uri.tryParse(url.trim());
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return null;
    }
    return uri;
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

Future<bool> _launchArticleExternally(Uri uri) {
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _ArticleMetadata extends StatelessWidget {
  const _ArticleMetadata({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.sourceName ?? 'Sumber tidak diketahui',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          article.author ?? 'Penulis tidak diketahui',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(
          ArticleMetadata.dateText(article.publishedAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
