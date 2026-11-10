import 'package:flutter/material.dart';
import 'package:news_app/theme/app_theme.dart';

class NewsFilters extends StatelessWidget {
  const NewsFilters({
    super.key,
    required this.enabled,
    required this.categories,
    required this.selectedCategory,
    required this.onSearchChanged,
    required this.onCategorySelected,
  });

  final bool enabled;
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.small,
        AppSpacing.page,
        AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WAWASAN HARI INI',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            'Berita Teknologi Terkini',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.large),
          TextField(
            key: const Key('news-search-field'),
            enabled: enabled,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Cari berita teknologi',
              prefixIcon: const Icon(Icons.search_outlined),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.medium,
                horizontal: AppSpacing.medium,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.pillRadius),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.pillRadius),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          Text('Topik pilihan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.small),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in categories)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.small),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: category == selectedCategory,
                      onSelected: enabled
                          ? (_) => onCategorySelected(category)
                          : null,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: category == selectedCategory
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSizes.pillRadius,
                        ),
                      ),
                      labelStyle: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                            color: category == selectedCategory
                                ? AppColors.onImage
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.small,
                        vertical: AppSpacing.small,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
