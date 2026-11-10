import 'package:flutter/material.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/theme/app_theme.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    this.onTap,
    this.featured = false,
  });

  final Article article;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback? onTap;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: featured ? _featuredContent() : _regularContent(context),
      ),
    );
  }

  Widget _featuredContent() {
    return SizedBox(
      height: AppSizes.featuredImageHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ArticleImage(
            imageUrl: article.urlToImage,
            height: AppSizes.featuredImageHeight,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.overlayTop, AppColors.overlayBottom],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _FeaturedLabel(),
                    const Spacer(),
                    _BookmarkButton(
                      isBookmarked: isBookmarked,
                      onPressed: onBookmarkToggle,
                      onImage: true,
                    ),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ArticleCategoryBadge(category: article.category),
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  article.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.onImageTitle,
                ),
                const SizedBox(height: AppSpacing.small),
                Text(
                  ArticleMetadata.text(article),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.onImageCaption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _regularContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final thumbnailSize = constraints.maxWidth < AppSizes.narrowCardWidth
            ? AppSizes.smallThumbnail
            : AppSizes.thumbnail;
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.medium),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: ArticleCategoryBadge(
                            category: article.category,
                          ),
                        ),
                        const Spacer(),
                        _BookmarkButton(
                          isBookmarked: isBookmarked,
                          onPressed: onBookmarkToggle,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      ArticleMetadata.text(article),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.medium),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.imageRadius),
                child: SizedBox(
                  width: thumbnailSize,
                  height: thumbnailSize,
                  child: ArticleImage(
                    imageUrl: article.urlToImage,
                    height: thumbnailSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeaturedLabel extends StatelessWidget {
  const _FeaturedLabel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.featuredBadge,
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        child: Text('SOROTAN', style: AppTextStyles.onImageCaption),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  const _BookmarkButton({
    required this.isBookmarked,
    required this.onPressed,
    this.onImage = false,
  });

  final bool isBookmarked;
  final VoidCallback onPressed;
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: isBookmarked ? 'Hapus dari favorit' : 'Simpan ke favorit',
      style: IconButton.styleFrom(
        backgroundColor: onImage ? AppColors.featuredBadge : AppColors.softBlue,
        foregroundColor: onImage ? AppColors.onImage : AppColors.primary,
      ),
      icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
    );
  }
}

class ArticleCategoryBadge extends StatelessWidget {
  const ArticleCategoryBadge({super.key, this.category});

  final String? category;

  @override
  Widget build(BuildContext context) {
    final label = category?.trim();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(AppSizes.pillRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.medium,
          vertical: AppSpacing.small,
        ),
        child: Text(
          label == null || label.isEmpty ? 'TEKNOLOGI' : label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class ArticleMetadata extends StatelessWidget {
  const ArticleMetadata({super.key, required this.article});

  final Article article;

  static String text(Article article) {
    final source = article.sourceName?.trim();
    final sourceText = source == null || source.isEmpty
        ? 'Sumber tidak diketahui'
        : source;
    final date = article.publishedAt;
    return date == null ? sourceText : '$sourceText  ·  ${dateText(date)}';
  }

  static String dateText(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) => Text(
    text(article),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: Theme.of(context).textTheme.bodySmall,
  );
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
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return _ImagePlaceholder(height: height);
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _ImagePlaceholder(height: height),
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
    final large = height >= AppSizes.articleImageHeight;
    return SizedBox(
      height: height,
      child: ColoredBox(
        color: AppColors.imageSurface,
        child: Center(
          child: Container(
            width: large ? 80 : 52,
            height: large ? 80 : 52,
            decoration: const BoxDecoration(
              color: AppColors.softBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: large ? 36 : 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
