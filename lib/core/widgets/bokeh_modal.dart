import 'dart:ui';

import 'package:flutter/material.dart';

Future<T?> showBokehModal<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  double maxWidth = 520,
  double blurSigma = 14,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (ctx, anim, secAnim, dialogChild) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
          child: dialogChild,
        ),
      );
    },
    pageBuilder: (ctx, anim, secAnim) {
      return _BokehBackdrop(
        blurSigma: blurSigma,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      );
    },
  );
}

class _BokehBackdrop extends StatelessWidget {
  const _BokehBackdrop({required this.blurSigma, required this.child});

  final double blurSigma;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurSigma,
            sigmaY: blurSigma,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: isDark
                    ? [
                        colors.surface.withAlpha(180),
                        colors.surface.withAlpha(220),
                      ]
                    : [
                        colors.scrim.withAlpha(30),
                        colors.scrim.withAlpha(70),
                      ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class BokehModalCard extends StatelessWidget {
  const BokehModalCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: isDark ? 12 : 8,
      shadowColor: colors.shadow.withAlpha(isDark ? 120 : 60),
      borderRadius: BorderRadius.circular(24),
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 20),
            body,
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!
                    .expand((w) => [w, const SizedBox(width: 8)])
                    .toList()
                  ..removeLast(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
