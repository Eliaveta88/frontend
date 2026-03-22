import 'package:flutter/material.dart';

import '../network/dio_error_mapper.dart';

/// Карточка ошибки загрузки с опциональным повтором запроса.
class AsyncErrorCard extends StatelessWidget {
  const AsyncErrorCard({
    super.key,
    required this.error,
    this.title = 'Не удалось загрузить данные',
    this.onRetry,
    this.hint,
  });

  final Object error;
  final String title;
  final VoidCallback? onRetry;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      color: colors.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: colors.onErrorContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.onErrorContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              dioErrorMessage(error),
              style: theme.textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
            ),
            if (hint != null && hint!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                hint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onErrorContainer.withValues(alpha: 0.85),
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: const Text('Повторить'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
