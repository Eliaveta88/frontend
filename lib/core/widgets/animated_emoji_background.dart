import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedEmojiBackground extends StatefulWidget {
  const AnimatedEmojiBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedEmojiBackground> createState() =>
      _AnimatedEmojiBackgroundState();
}

class _AnimatedEmojiBackgroundState extends State<AnimatedEmojiBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late List<_EmojiParticle> _particles;

  static const _emojis = ['📦', '📦', '📦', '🧾', '🚚'];

  @override
  void initState() {
    super.initState();
    _particles = [];
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_particles.isEmpty) {
      _particles = _generateParticles(MediaQuery.sizeOf(context));
    }
  }

  List<_EmojiParticle> _generateParticles(Size size) {
    final rng = Random(42);
    final w = size.width;
    final count = (w / 120).clamp(8, 30).toInt();
    return List.generate(count, (_) {
      final emoji = _emojis[rng.nextInt(_emojis.length)];
      return _EmojiParticle(
        emoji: emoji,
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 18.0 + rng.nextDouble() * 16,
        speed: 0.003 + rng.nextDouble() * 0.006,
        drift: (rng.nextDouble() - 0.5) * 0.002,
        opacity: 0.035 + rng.nextDouble() * 0.04,
        phase: rng.nextDouble() * 2 * pi,
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final overlayColor = Theme.of(context).colorScheme.onSurfaceVariant;
            return CustomPaint(
              painter: _EmojiPainter(_particles, _ctrl.value, overlayColor),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _EmojiParticle {
  _EmojiParticle({
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.opacity,
    required this.phase,
  });

  final String emoji;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double drift;
  final double opacity;
  final double phase;
}

class _EmojiPainter extends CustomPainter {
  _EmojiPainter(this.particles, this.t, this.overlayColor);

  final List<_EmojiParticle> particles;
  final double t;
  final Color overlayColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final progress = (t * 60 * p.speed + p.y) % 1.2 - 0.1;
      final py = size.height * (1.0 - progress);
      final wobble = sin(t * 2 * pi * 3 + p.phase) * 20;
      final px = size.width * p.x + wobble;

      final tp = TextPainter(
        text: TextSpan(
          text: p.emoji,
          style: TextStyle(fontSize: p.size),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(px, py);
      final paint =
          Paint()..color = overlayColor.withAlpha((p.opacity * 255).toInt());
      canvas.saveLayer(Rect.fromLTWH(0, 0, tp.width, tp.height), paint);
      tp.paint(canvas, Offset.zero);
      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_EmojiPainter old) => true;
}
