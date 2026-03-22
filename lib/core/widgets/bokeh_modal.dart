import 'dart:ui';

import 'package:flutter/material.dart';

/// Модальное окно: боке и размытие нарастают по той же кривой, что и появление карточки.
Future<T?> showBokehModal<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  double maxWidth = 520,
  double maxHeightFactor = 0.92,
  double blurSigma = 20,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 480),
    // Вся анимация внутри [pageBuilder] — общий [Animation] для фона и окна.
    transitionBuilder: (ctx, anim, secAnim, dialogChild) => dialogChild,
    pageBuilder: (ctx, anim, secAnim) {
      final smooth = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInQuart,
      );
      final scale = Tween<double>(begin: 0.965, end: 1.0).animate(smooth);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.028),
        end: Offset.zero,
      ).animate(smooth);

      return Stack(
        fit: StackFit.expand,
        children: [
          _BokehBackdrop(
            intensity: smooth,
            blurSigma: blurSigma,
          ),
          SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: MediaQuery.sizeOf(ctx).height * maxHeightFactor,
                ),
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: smooth,
                    child: SlideTransition(
                      position: slide,
                      child: ScaleTransition(
                        scale: scale,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Размытие, затемнение и боке: интенсивность = [intensity] (синхронно с окном).
class _BokehBackdrop extends StatelessWidget {
  const _BokehBackdrop({
    required this.intensity,
    required this.blurSigma,
  });

  final Animation<double> intensity;
  final double blurSigma;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scrimTop = isDark ? const Color(0xFF000000) : const Color(0xFF1A1A1A);
    final scrimBot = isDark ? const Color(0xFF050508) : const Color(0xFF2A2A2E);

    return AnimatedBuilder(
      animation: intensity,
      builder: (context, _) {
        final t = intensity.value.clamp(0.0, 1.0);
        final sigma = blurSigma * t;

        return Stack(
          fit: StackFit.expand,
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: sigma,
                sigmaY: sigma,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      scrimTop.withAlpha(((isDark ? 150 : 120) * t).round().clamp(0, 255)),
                      scrimBot.withAlpha(((isDark ? 200 : 160) * t).round().clamp(0, 255)),
                    ],
                  ),
                ),
              ),
            ),
            CustomPaint(
              painter: _BokehOrbsPainter(
                primary: colors.primary,
                secondary: colors.secondary,
                tertiary: colors.tertiary,
                isDark: isDark,
                intensity: t,
              ),
              size: Size.infinite,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.15,
                  colors: [
                    Colors.transparent,
                    (isDark ? Colors.black : Colors.black87).withAlpha(
                      ((isDark ? 110 : 50) * t).round().clamp(0, 255),
                    ),
                  ],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Рисует мягкие пятна боке; альфа умножается на [intensity].
class _BokehOrbsPainter extends CustomPainter {
  _BokehOrbsPainter({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.isDark,
    required this.intensity,
  });

  final Color primary;
  final Color secondary;
  final Color tertiary;
  final bool isDark;
  final double intensity;

  void _orb(Canvas canvas, Offset c, double r, Color color, double opacityMul) {
    final base = isDark ? 0.55 : 0.42;
    final t = intensity.clamp(0.0, 1.0);
    final a = (255 * base * opacityMul * t).round().clamp(0, 255);
    if (a < 3) return;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withAlpha(a),
          color.withAlpha(0),
        ],
        stops: const [0.15, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = size.shortestSide;

    _orb(canvas, Offset(w * 0.12, h * 0.18), s * 0.42, primary, 1.0);
    _orb(canvas, Offset(w * 0.88, h * 0.12), s * 0.36, secondary, 0.85);
    _orb(canvas, Offset(w * 0.55, h * 0.72), s * 0.48, tertiary, 0.75);
    _orb(canvas, Offset(w * 0.08, h * 0.65), s * 0.28, secondary, 0.55);
    _orb(canvas, Offset(w * 0.92, h * 0.55), s * 0.32, primary, 0.6);
    _orb(canvas, Offset(w * 0.42, h * 0.35), s * 0.22, tertiary, 0.45);
    _orb(canvas, Offset(w * 0.72, h * 0.88), s * 0.26, primary, 0.5);
  }

  @override
  bool shouldRepaint(covariant _BokehOrbsPainter old) =>
      old.primary != primary ||
      old.secondary != secondary ||
      old.tertiary != tertiary ||
      old.isDark != isDark ||
      old.intensity != intensity;
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
      elevation: isDark ? 18 : 12,
      shadowColor: colors.shadow.withAlpha(isDark ? 150 : 80),
      surfaceTintColor: Colors.transparent,
      color: colors.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: colors.outlineVariant.withAlpha(isDark ? 100 : 75),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.35,
                height: 1.2,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 22),
            body,
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 26),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 10,
                runSpacing: 10,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
