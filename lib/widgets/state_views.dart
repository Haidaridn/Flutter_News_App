import 'package:flutter/material.dart';
import 'package:news_app/theme/app_theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _StateViewLayout(
      indicator: CircularProgressIndicator(),
      message: 'Sedang memuat berita...',
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateViewLayout(
      indicator: Icon(
        Icons.cloud_off_outlined,
        size: AppSizes.stateIcon,
        color: Theme.of(context).colorScheme.error,
      ),
      message: message,
      action: FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Coba lagi'),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return _StateViewLayout(
      indicator: Icon(
        Icons.article_outlined,
        size: AppSizes.stateIcon,
        color: Theme.of(context).colorScheme.primary,
      ),
      message: 'Belum ada berita untuk ditampilkan.',
    );
  }
}

class _StateViewLayout extends StatelessWidget {
  const _StateViewLayout({
    required this.indicator,
    required this.message,
    this.action,
  });

  final Widget indicator;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            indicator,
            const SizedBox(height: AppSpacing.medium),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.medium),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
