import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/theme/app_theme.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article, this.onTap});

  final Article article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ArticleImage(imageUrl: article.urlToImage),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  Text(
                    _metadataText(article),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _metadataText(Article article) {
    final source = article.sourceName ?? 'Sumber tidak diketahui';
    final publishedDate = article.publishedAt;

    if (publishedDate == null) {
      return source;
    }

    final day = publishedDate.day.toString().padLeft(2, '0');
    final month = publishedDate.month.toString().padLeft(2, '0');
    return '$source - $day/$month/${publishedDate.year}';
  }
}

class ArticleImage extends StatelessWidget {
  const ArticleImage({
    super.key,
    required this.imageUrl,
    this.height = AppSizes.articleImageHeight,
  });

  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return _ImagePlaceholder(height: height);
    }

    return SizedBox(
      height: height,
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _ImagePlaceholder(height: height),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: AppSizes.stateIcon,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
