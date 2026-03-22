import 'package:flutter/material.dart';

/// Короткая серая полоска-плейсхолдер.
class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius = 6,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Имитация таблицы (DataTable) на время загрузки.
class TableLoadingSkeleton extends StatelessWidget {
  const TableLoadingSkeleton({
    super.key,
    required this.columnCount,
    this.rowCount = 6,
    this.showHeader = true,
  });

  final int columnCount;
  final int rowCount;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final divider = theme.dividerColor;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  for (var i = 0; i < columnCount; i++) ...[
                    Expanded(
                      flex: i == 0 ? 2 : 3,
                      child: Padding(
                        padding: EdgeInsets.only(right: i < columnCount - 1 ? 12 : 0),
                        child: const SkeletonLine(height: 12, width: 56),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: divider),
          ],
          for (var r = 0; r < rowCount; r++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  for (var c = 0; c < columnCount; c++) ...[
                    Expanded(
                      flex: c == 0 ? 2 : 3,
                      child: Padding(
                        padding: EdgeInsets.only(right: c < columnCount - 1 ? 12 : 0),
                        child: SkeletonLine(
                          height: 14,
                          width: c == columnCount - 1 ? 48 : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (r < rowCount - 1) Divider(height: 1, indent: 16, endIndent: 16, color: divider),
          ],
        ],
      ),
    );
  }
}

/// Скелетон карточек KPI на дашборде.
class DashboardKpiSkeleton extends StatelessWidget {
  const DashboardKpiSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(
        4,
        (_) => SizedBox(
          width: 200,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 120, height: 12),
                  const SizedBox(height: 12),
                  SkeletonLine(width: 80, height: 28),
                  const SizedBox(height: 8),
                  SkeletonLine(width: 160, height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Весь экран дашборда в состоянии загрузки.
class DashboardLoadingSkeleton extends StatelessWidget {
  const DashboardLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SkeletonLine(width: 180, height: 28),
        const SizedBox(height: 8),
        SkeletonLine(width: 260, height: 16),
        const SizedBox(height: 28),
        Text('Ключевые показатели', style: theme.textTheme.titleMedium),
        const SizedBox(height: 16),
        const DashboardKpiSkeleton(),
        const SizedBox(height: 32),
        SkeletonLine(width: 200, height: 18),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 100, height: 14),
                const SizedBox(height: 12),
                SkeletonLine(height: 12),
                const SizedBox(height: 8),
                SkeletonLine(width: 220, height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Блок «баланс + список» для страницы финансов.
class FinanceLoadingSkeleton extends StatelessWidget {
  const FinanceLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Счёт', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 200, height: 16),
                const SizedBox(height: 12),
                const SkeletonLine(width: 280, height: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Транзакции', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              for (var i = 0; i < 4; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SkeletonLine(width: 160, height: 14),
                            const SizedBox(height: 8),
                            SkeletonLine(width: 100, height: 10),
                          ],
                        ),
                      ),
                      const SkeletonLine(width: 56, height: 16),
                    ],
                  ),
                ),
                if (i < 3) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
