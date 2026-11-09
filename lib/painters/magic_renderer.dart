import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/drawing_action.dart';

class MagicRenderer {
  MagicRenderer._();

  static final Paint _paint = Paint();
  static final Path _path = Path();
  static final math.Random _random = math.Random(42);

  static void drawMagic(Canvas canvas, MagicAction action) {
    if (action.points.isEmpty) return;

    switch (action.magicType) {
      case MagicType.grass:
        _drawGrass(canvas, action.points, action.color, action.strokeWidth);
      case MagicType.rainbow:
        _drawRainbowRibbon(canvas, action.points, action.strokeWidth);
      case MagicType.realRainbow:
        _drawRealRainbowArc(canvas, action.points, action.strokeWidth);
      case MagicType.bricks:
        _drawBricks(canvas, action.points, action.color, action.isLarge);
      case MagicType.chalk:
        _drawChalk(canvas, action.points, action.color, action.strokeWidth);
      case MagicType.blur:
        _drawBlur(canvas, action.points, action.strokeWidth);
      case MagicType.rails:
        _drawRails(canvas, action.points, action.strokeWidth);
      case MagicType.foam:
        _drawFoam(canvas, action.points, action.strokeWidth);
      case MagicType.confetti:
        _drawConfetti(canvas, action.points, action.strokeWidth);
      case MagicType.flower:
        _drawFlowers(canvas, action.points, action.color, action.strokeWidth);
    }
  }

  // 1. Authentic Tux Paint Grass: procedural blades sprouting with height variation and shading
  static void _drawGrass(Canvas canvas, List<Offset> points, Color color, double strokeWidth) {
    _paint.style = PaintingStyle.stroke;
    _paint.strokeCap = StrokeCap.round;
    _paint.maskFilter = null;

    final rand = math.Random(points.first.dx.toInt() ^ points.first.dy.toInt());
    final bladeCount = math.max(3, (strokeWidth / 5).round());

    for (int i = 0; i < points.length; i++) {
      final base = points[i];
      for (int b = 0; b < bladeCount; b++) {
        final offsetX = (rand.nextDouble() - 0.5) * strokeWidth;
        final bladeHeight = strokeWidth * (0.8 + rand.nextDouble() * 0.9);
        final curve = (rand.nextDouble() - 0.5) * 20.0;

        // Color shading (grass gradient tones)
        final shade = 0.8 + rand.nextDouble() * 0.4;
        final bladeColor = Color.fromARGB(
          255,
          (color.r * 255 * 0.6).clamp(0, 255).toInt(),
          (color.g * 255 * shade).clamp(0, 255).toInt(),
          (color.b * 255 * 0.4).clamp(0, 255).toInt(),
        );

        _paint.color = bladeColor;
        _paint.strokeWidth = math.max(1.5, strokeWidth * 0.08);

        _path.reset();
        _path.moveTo(base.dx + offsetX, base.dy);
        _path.quadraticBezierTo(
          base.dx + offsetX + curve * 0.5,
          base.dy - bladeHeight * 0.5,
          base.dx + offsetX + curve,
          base.dy - bladeHeight,
        );
        canvas.drawPath(_path, _paint);
      }
    }
  }

  // 2. Rainbow Ribbon
  static void _drawRainbowRibbon(Canvas canvas, List<Offset> points, double strokeWidth) {
    if (points.length < 2) return;
    const colors = [
      Color(0xFFFF0000),
      Color(0xFFFF7F00),
      Color(0xFFFFFF00),
      Color(0xFF00FF00),
      Color(0xFF0000FF),
      Color(0xFF4B0082),
      Color(0xFF9400D3),
    ];

    _paint.style = PaintingStyle.stroke;
    _paint.strokeCap = StrokeCap.round;
    _paint.strokeJoin = StrokeJoin.round;
    _paint.maskFilter = null;

    final stripeWidth = math.max(2.0, strokeWidth / colors.length);
    for (int c = 0; c < colors.length; c++) {
      _paint.color = colors[c];
      _paint.strokeWidth = stripeWidth;
      final offsetDist = (c - colors.length / 2) * stripeWidth;

      _path.reset();
      for (int i = 0; i < points.length; i++) {
        final pt = points[i];
        final Offset normal;
        if (i < points.length - 1) {
          final diff = points[i + 1] - pt;
          final len = diff.distance;
          normal = len > 0 ? Offset(-diff.dy / len, diff.dx / len) : Offset.zero;
        } else {
          final diff = pt - points[i - 1];
          final len = diff.distance;
          normal = len > 0 ? Offset(-diff.dy / len, diff.dx / len) : Offset.zero;
        }
        final shifted = pt + normal * offsetDist;
        if (i == 0) {
          _path.moveTo(shifted.dx, shifted.dy);
        } else {
          _path.lineTo(shifted.dx, shifted.dy);
        }
      }
      canvas.drawPath(_path, _paint);
    }
  }

  // 3. Real Rainbow Arc
  static void _drawRealRainbowArc(Canvas canvas, List<Offset> points, double strokeWidth) {
    if (points.length < 2) return;
    final start = points.first;
    final end = points.last;
    final rect = Rect.fromPoints(start, end);

    const colors = [
      Color(0x44FF0000),
      Color(0x44FF7F00),
      Color(0x44FFFF00),
      Color(0x4400FF00),
      Color(0x440000FF),
      Color(0x444B0082),
      Color(0x449400D3),
    ];

    _paint.style = PaintingStyle.stroke;
    _paint.strokeCap = StrokeCap.round;
    _paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final stripe = strokeWidth / colors.length;
    for (int i = 0; i < colors.length; i++) {
      _paint.color = colors[i];
      _paint.strokeWidth = stripe * 2;
      canvas.drawArc(rect.inflate(i * stripe), math.pi, math.pi, false, _paint);
    }
  }

  // 4. Authentic Tux Paint Bricks: aligned mortared masonry wall grid
  static void _drawBricks(Canvas canvas, List<Offset> points, Color color, bool isLarge) {
    final double bw = isLarge ? 48.0 : 24.0;
    final double bh = isLarge ? 24.0 : 12.0;
    final double mortar = isLarge ? 3.0 : 2.0;

    _paint.style = PaintingStyle.fill;
    _paint.maskFilter = null;

    final paintedBricks = <int>{};
    for (final pt in points) {
      final int row = (pt.dy / bh).floor();
      final double rowOffset = (row % 2 == 0) ? 0.0 : bw / 2;
      final int col = ((pt.dx - rowOffset) / bw).floor();
      final brickKey = (row << 16) ^ (col & 0xFFFF);

      if (paintedBricks.add(brickKey)) {
        final bx = col * bw + rowOffset + mortar / 2;
        final by = row * bh + mortar / 2;
        final rect = Rect.fromLTWH(bx, by, bw - mortar, bh - mortar);

        // Brick texture shading variation
        final rand = math.Random(brickKey);
        final shade = 0.85 + rand.nextDouble() * 0.3;
        _paint.color = Color.fromARGB(
          255,
          (color.r * 255 * shade).clamp(0, 255).toInt(),
          (color.g * 255 * shade).clamp(0, 255).toInt(),
          (color.b * 255 * shade).clamp(0, 255).toInt(),
        );

        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), _paint);
      }
    }
  }

  // 5. Chalk Effect: powdery, noisy texture
  static void _drawChalk(Canvas canvas, List<Offset> points, Color color, double strokeWidth) {
    _paint.style = PaintingStyle.fill;
    _paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    final rand = _random;
    final dotCount = (strokeWidth * 1.5).round();

    for (final pt in points) {
      for (int i = 0; i < dotCount; i++) {
        final rad = rand.nextDouble() * (strokeWidth / 2);
        final ang = rand.nextDouble() * math.pi * 2;
        final alpha = 0.15 + rand.nextDouble() * 0.55;

        _paint.color = color.withValues(alpha: alpha);
        canvas.drawCircle(
          Offset(pt.dx + rad * math.cos(ang), pt.dy + rad * math.sin(ang)),
          1.0 + rand.nextDouble() * 2.5,
          _paint,
        );
      }
    }
  }

  // 6. Blur Effect: soft diffusion halo
  static void _drawBlur(Canvas canvas, List<Offset> points, double strokeWidth) {
    if (points.length < 2) return;
    _paint.style = PaintingStyle.stroke;
    _paint.strokeCap = StrokeCap.round;
    _paint.strokeJoin = StrokeJoin.round;
    _paint.color = Colors.white.withValues(alpha: 0.25);
    _paint.strokeWidth = strokeWidth * 1.5;
    _paint.maskFilter = MaskFilter.blur(BlurStyle.normal, strokeWidth * 0.5);

    _path.reset();
    _path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      _path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(_path, _paint);
  }

  // 7. Rails (Train Tracks): dual parallel steel rails with transverse wooden ties
  static void _drawRails(Canvas canvas, List<Offset> points, double strokeWidth) {
    if (points.length < 2) return;
    final trackGauge = math.max(14.0, strokeWidth);

    _paint.style = PaintingStyle.stroke;
    _paint.strokeCap = StrokeCap.butt;
    _paint.maskFilter = null;

    // 1. Draw transverse wooden sleepers
    _paint.color = const Color(0xFF5D4037);
    _paint.strokeWidth = math.max(3.0, strokeWidth * 0.25);

    const tieSpacing = 16.0;
    double distTraveled = 0.0;

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final seg = p1 - p0;
      final segLen = seg.distance;
      if (segLen <= 0.001) continue;

      final norm = Offset(-seg.dy / segLen, seg.dx / segLen);

      while (distTraveled <= segLen) {
        final t = distTraveled / segLen;
        final center = Offset(p0.dx + seg.dx * t, p0.dy + seg.dy * t);
        canvas.drawLine(
          center - norm * (trackGauge * 0.8),
          center + norm * (trackGauge * 0.8),
          _paint,
        );
        distTraveled += tieSpacing;
      }
      distTraveled -= segLen;
    }

    // 2. Draw dual steel rails
    _paint.color = const Color(0xFF78909C);
    _paint.strokeWidth = math.max(2.0, strokeWidth * 0.15);

    for (final side in [-1.0, 1.0]) {
      _path.reset();
      for (int i = 0; i < points.length; i++) {
        final pt = points[i];
        final Offset normal;
        if (i < points.length - 1) {
          final diff = points[i + 1] - pt;
          final len = diff.distance;
          normal = len > 0 ? Offset(-diff.dy / len, diff.dx / len) : Offset.zero;
        } else {
          final diff = pt - points[i - 1];
          final len = diff.distance;
          normal = len > 0 ? Offset(-diff.dy / len, diff.dx / len) : Offset.zero;
        }
        final railPt = pt + normal * (trackGauge * 0.5 * side);
        if (i == 0) {
          _path.moveTo(railPt.dx, railPt.dy);
        } else {
          _path.lineTo(railPt.dx, railPt.dy);
        }
      }
      canvas.drawPath(_path, _paint);
    }
  }

  // 8. Foam / Bubbles
  static void _drawFoam(Canvas canvas, List<Offset> points, double strokeWidth) {
    _paint.style = PaintingStyle.stroke;
    _paint.maskFilter = null;
    final rand = _random;

    for (final pt in points) {
      for (int i = 0; i < 4; i++) {
        final r = 3.0 + rand.nextDouble() * (strokeWidth * 0.4);
        final ox = (rand.nextDouble() - 0.5) * strokeWidth;
        final oy = (rand.nextDouble() - 0.5) * strokeWidth;
        final center = Offset(pt.dx + ox, pt.dy + oy);

        _paint.color = Colors.white.withValues(alpha: 0.8);
        _paint.strokeWidth = 1.5;
        canvas.drawCircle(center, r, _paint);

        // Bubble highlight reflection
        _paint.style = PaintingStyle.fill;
        _paint.color = Colors.white.withValues(alpha: 0.9);
        canvas.drawCircle(Offset(center.dx - r * 0.3, center.dy - r * 0.3), r * 0.25, _paint);
        _paint.style = PaintingStyle.stroke;
      }
    }
  }

  // 9. Confetti
  static void _drawConfetti(Canvas canvas, List<Offset> points, double strokeWidth) {
    _paint.style = PaintingStyle.fill;
    _paint.maskFilter = null;
    const colors = [
      Color(0xFFFF0055),
      Color(0xFF00DDFF),
      Color(0xFFFFCC00),
      Color(0xFF00FF66),
      Color(0xFF9900FF),
    ];
    final rand = _random;

    for (final pt in points) {
      for (int i = 0; i < 5; i++) {
        final ox = (rand.nextDouble() - 0.5) * strokeWidth * 1.5;
        final oy = (rand.nextDouble() - 0.5) * strokeWidth * 1.5;
        final size = 4.0 + rand.nextDouble() * 8.0;
        final angle = rand.nextDouble() * math.pi;

        _paint.color = colors[rand.nextInt(colors.length)];

        canvas.save();
        canvas.translate(pt.dx + ox, pt.dy + oy);
        canvas.rotate(angle);
        canvas.drawRect(Rect.fromLTWH(-size / 2, -size / 4, size, size / 2), _paint);
        canvas.restore();
      }
    }
  }

  // 10. Flowers
  static void _drawFlowers(Canvas canvas, List<Offset> points, Color color, double strokeWidth) {
    _paint.style = PaintingStyle.fill;
    _paint.maskFilter = null;
    final r = math.max(8.0, strokeWidth * 0.6);

    for (final pt in points) {
      // Petals
      _paint.color = color;
      const numPetals = 5;
      for (int i = 0; i < numPetals; i++) {
        final angle = i * (math.pi * 2 / numPetals);
        final petalCenter = Offset(pt.dx + r * 0.6 * math.cos(angle), pt.dy + r * 0.6 * math.sin(angle));
        canvas.drawCircle(petalCenter, r * 0.45, _paint);
      }
      // Center pistil
      _paint.color = const Color(0xFFFFD54F);
      canvas.drawCircle(pt, r * 0.35, _paint);
    }
  }
}
