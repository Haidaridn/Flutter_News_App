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
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.medium,
          AppSpacing.small,
          AppSpacing.medium,
          AppSpacing.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('news-search-field'),
              enabled: enabled,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari judul atau sumber berita',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.medium),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.medium),
            Text('Kategori', style: Theme.of(context).textTheme.bodyMedium),
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
}
