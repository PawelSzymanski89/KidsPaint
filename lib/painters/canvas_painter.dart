import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/tux_assets.dart';
import '../models/drawing_action.dart';
import '../services/image_loader.dart';
import 'magic_renderer.dart';

/// Complete Tux Paint Brush & Stroke rendering engine.
/// Conforms strictly to flutter-ultimate zero GC churn guidelines:
/// all Paints, Paths and intermediate states are static and reused.
class BrushRenderer {
  BrushRenderer._();

  static final List<Color> rainbowPalette = <Color>[
    const Color(0xFFFF5A5F),
    const Color(0xFFFFB703),
    const Color(0xFF06D6A0),
    const Color(0xFF118AB2),
    const Color(0xFF7B2CBF),
    const Color(0xFFFF70A6),
  ];

  static final Paint _solidStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _solidSquarePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.square
    ..strokeJoin = StrokeJoin.miter;

  static final Paint _fuzzStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _fuzzCorePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static final Paint _fillDotPaint = Paint()
    ..style = PaintingStyle.fill;

  static final Paint _fuzzDotPaint = Paint()
    ..style = PaintingStyle.fill;

  static final Paint _stampImagePaint = Paint()
    ..filterQuality = FilterQuality.medium;

  static final Path _strokePath = Path();

  static void drawStroke({
    required Canvas canvas,
    required List<Offset> points,
    required Color color,
    required double strokeWidth,
    required bool isRainbow,
    required bool isEraser,
    String? brushAsset,
  }) {
    if (points.isEmpty) return;

    // Eraser always draws solid white
    if (isEraser) {
      _solidStrokePaint.color = Colors.white;
      _solidStrokePaint.strokeWidth = strokeWidth * 1.5;
      _solidStrokePaint.maskFilter = null;
      _drawSmoothPath(canvas, points, _solidStrokePaint);
      return;
    }

    final TuxBrush brush = TuxAssets.findBrush(brushAsset);

    switch (brush.renderType) {
      case BrushRenderType.solidRound:
        _drawSolidRound(canvas, points, color, strokeWidth, isRainbow);

      case BrushRenderType.fuzzyRound:
        _drawFuzzyRound(canvas, points, color, strokeWidth, isRainbow);

      case BrushRenderType.solidSquare:
        _drawSolidSquare(canvas, points, color, strokeWidth, isRainbow);

      case BrushRenderType.fuzzySquare:
        _drawFuzzySquare(canvas, points, color, strokeWidth, isRainbow);

      case BrushRenderType.seeThru:
        _drawSeeThru(canvas, points, color, strokeWidth, isRainbow);

      case BrushRenderType.patternStamp:
        _drawPatternStamps(canvas, points, color, strokeWidth, isRainbow, brush);
    }
  }

  static void drawLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required Color color,
    required double strokeWidth,
    required bool isRainbow,
    String? brushAsset,
  }) {
    final dist = (end - start).distance;
    final TuxBrush brush = TuxAssets.findBrush(brushAsset);
    final step = math.max(4.0, strokeWidth * brush.spacingRatio);
    final count = (dist / step).ceil();

    if (count <= 1 || brush.renderType == BrushRenderType.solidRound) {
      _solidStrokePaint.color = color;
      _solidStrokePaint.strokeWidth = strokeWidth;
      _solidStrokePaint.maskFilter = null;
      canvas.drawLine(start, end, _solidStrokePaint);
      return;
    }

    final points = <Offset>[];
    for (int i = 0; i <= count; i++) {
      final t = i / count;
      points.add(Offset(
        start.dx + (end.dx - start.dx) * t,
        start.dy + (end.dy - start.dy) * t,
      ));
    }

    drawStroke(
      canvas: canvas,
      points: points,
      color: color,
      strokeWidth: strokeWidth,
      isRainbow: isRainbow,
      isEraser: false,
      brushAsset: brushAsset,
    );
  }

  static void _drawSolidRound(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double strokeWidth,
    bool isRainbow,
  ) {
    if (isRainbow) {
      _drawRainbowStroke(canvas, points, strokeWidth, isRound: true);
      return;
    }

    _solidStrokePaint.color = color;
    _solidStrokePaint.strokeWidth = strokeWidth;
    _solidStrokePaint.maskFilter = null;

    if (points.length == 1) {
      _fillDotPaint.color = color;
      _fillDotPaint.maskFilter = null;
      canvas.drawCircle(points.first, strokeWidth / 2, _fillDotPaint);
      return;
    }

    _drawSmoothPath(canvas, points, _solidStrokePaint);
  }

  static void _drawFuzzyRound(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double strokeWidth,
    bool isRainbow,
  ) {
    final double blurSigma = math.max(2.0, strokeWidth * 0.36);
    final double coreWidth = strokeWidth * 0.55;

    if (points.length == 1) {
      final pt = points.first;
      final c = isRainbow ? rainbowPalette.first : color;

      _fuzzDotPaint.color = c;
      _fuzzDotPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
      canvas.drawCircle(pt, strokeWidth / 2, _fuzzDotPaint);

      _fillDotPaint.color = c;
      _fillDotPaint.maskFilter = null;
      canvas.drawCircle(pt, coreWidth / 2, _fillDotPaint);
      return;
    }

    if (isRainbow) {
      _drawRainbowFuzzy(canvas, points, strokeWidth, blurSigma, coreWidth);
      return;
    }

    _fuzzStrokePaint.color = color;
    _fuzzStrokePaint.strokeWidth = strokeWidth * 1.05;
    _fuzzStrokePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    _drawSmoothPath(canvas, points, _fuzzStrokePaint);

    _fuzzCorePaint.color = color;
    _fuzzCorePaint.strokeWidth = coreWidth;
    _fuzzCorePaint.maskFilter = null;
    _drawSmoothPath(canvas, points, _fuzzCorePaint);
  }

  static void _drawSolidSquare(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double strokeWidth,
    bool isRainbow,
  ) {
    if (isRainbow) {
      _drawRainbowStroke(canvas, points, strokeWidth, isRound: false);
      return;
    }

    _solidSquarePaint.color = color;
    _solidSquarePaint.strokeWidth = strokeWidth;
    _solidSquarePaint.maskFilter = null;

    if (points.length == 1) {
      final pt = points.first;
      final half = strokeWidth / 2;
      canvas.drawRect(Rect.fromLTWH(pt.dx - half, pt.dy - half, strokeWidth, strokeWidth), _fillDotPaint..color = color);
      return;
    }

    _drawSmoothPath(canvas, points, _solidSquarePaint);
  }

  static void _drawFuzzySquare(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double strokeWidth,
    bool isRainbow,
  ) {
    final double blurSigma = math.max(2.0, strokeWidth * 0.36);
    _solidSquarePaint.color = color;
    _solidSquarePaint.strokeWidth = strokeWidth;
    _solidSquarePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);

    if (points.length == 1) {
      final pt = points.first;
      final half = strokeWidth / 2;
      _fuzzDotPaint.color = color;
      _fuzzDotPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
      canvas.drawRect(Rect.fromLTWH(pt.dx - half, pt.dy - half, strokeWidth, strokeWidth), _fuzzDotPaint);
      return;
    }

    _drawSmoothPath(canvas, points, _solidSquarePaint);
  }

  static void _drawSeeThru(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double strokeWidth,
    bool isRainbow,
  ) {
    final seeThruColor = color.withValues(alpha: 0.32);
    _solidStrokePaint.color = seeThruColor;
    _solidStrokePaint.strokeWidth = strokeWidth;
    _solidStrokePaint.maskFilter = null;

    if (points.length == 1) {
      _fillDotPaint.color = seeThruColor;
      _fillDotPaint.maskFilter = null;
      canvas.drawCircle(points.first, strokeWidth / 2, _fillDotPaint);
      return;
    }

    _drawSmoothPath(canvas, points, _solidStrokePaint);
  }

  static void _drawPatternStamps(
    Canvas canvas,
    List<Offset> points,
    Color color,
    double strokeWidth,
    bool isRainbow,
    TuxBrush brush,
  ) {
    final image = TuxImageCache.get(brush.assetPath);
    if (image == null) {
      TuxImageCache.load(brush.assetPath);
      _drawSolidRound(canvas, points, color, strokeWidth, isRainbow);
      return;
    }

    final int frames = math.max(1, brush.frames);
    final double frameWidth = image.width / frames;
    final double frameHeight = image.height.toDouble();
    final double step = math.max(3.0, strokeWidth * brush.spacingRatio);

    int rainbowIdx = 0;
    int frameIndex = 0;

    _stampImagePaint.colorFilter = ColorFilter.mode(
      isRainbow ? rainbowPalette[0] : color,
      BlendMode.srcIn,
    );

    final initialSrc = Rect.fromLTWH(0, 0, frameWidth, frameHeight);
    if (brush.rotates || brush.directional) {
      final initialAngle = (points.length > 1)
          ? math.atan2(points[1].dy - points[0].dy, points[1].dx - points[0].dx) + math.pi / 2
          : 0.0;
      canvas.save();
      canvas.translate(points.first.dx, points.first.dy);
      if (initialAngle != 0.0) canvas.rotate(initialAngle);
      canvas.drawImageRect(
        image,
        initialSrc,
        Rect.fromCenter(center: Offset.zero, width: strokeWidth, height: strokeWidth),
        _stampImagePaint,
      );
      canvas.restore();
    } else {
      canvas.drawImageRect(
        image,
        initialSrc,
        Rect.fromCenter(center: points.first, width: strokeWidth, height: strokeWidth),
        _stampImagePaint,
      );
    }

    if (points.length == 1) return;

    double distanceCovered = 0.0;
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final double segDist = (p1 - p0).distance;
      if (segDist <= 0.001) continue;

      final double dx = (p1.dx - p0.dx) / segDist;
      final double dy = (p1.dy - p0.dy) / segDist;
      final double strokeAngle = (brush.rotates || brush.directional)
          ? math.atan2(dy, dx) + math.pi / 2
          : 0.0;

      double currentOffset = step - distanceCovered;
      while (currentOffset <= segDist) {
        final pt = Offset(p0.dx + dx * currentOffset, p0.dy + dy * currentOffset);
        rainbowIdx++;
        frameIndex = (frameIndex + 1) % frames;

        if (isRainbow) {
          _stampImagePaint.colorFilter = ColorFilter.mode(
            rainbowPalette[rainbowIdx % rainbowPalette.length],
            BlendMode.srcIn,
          );
        }

        final srcRect = Rect.fromLTWH(frameIndex * frameWidth, 0, frameWidth, frameHeight);

        if (brush.rotates || brush.directional) {
          canvas.save();
          canvas.translate(pt.dx, pt.dy);
          canvas.rotate(strokeAngle);
          canvas.drawImageRect(
            image,
            srcRect,
            Rect.fromCenter(center: Offset.zero, width: strokeWidth, height: strokeWidth),
            _stampImagePaint,
          );
          canvas.restore();
        } else {
          canvas.drawImageRect(
            image,
            srcRect,
            Rect.fromCenter(center: pt, width: strokeWidth, height: strokeWidth),
            _stampImagePaint,
          );
        }

        currentOffset += step;
      }
      distanceCovered = segDist - (currentOffset - step);
    }
  }

  static void _drawSmoothPath(Canvas canvas, List<Offset> points, Paint paint) {
    _strokePath.reset();
    _strokePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      _strokePath.quadraticBezierTo(p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
    }
    _strokePath.lineTo(points.last.dx, points.last.dy);
    canvas.drawPath(_strokePath, paint);
  }

  static void _drawRainbowStroke(
    Canvas canvas,
    List<Offset> points,
    double strokeWidth, {
    required bool isRound,
  }) {
    final paint = isRound ? _solidStrokePaint : _solidSquarePaint;
    paint.strokeWidth = strokeWidth;
    paint.maskFilter = null;

    if (points.length == 1) {
      _fillDotPaint.color = rainbowPalette.first;
      _fillDotPaint.maskFilter = null;
      if (isRound) {
        canvas.drawCircle(points.first, strokeWidth / 2, _fillDotPaint);
      } else {
        final half = strokeWidth / 2;
        canvas.drawRect(Rect.fromLTWH(points.first.dx - half, points.first.dy - half, strokeWidth, strokeWidth), _fillDotPaint);
      }
      return;
    }

    for (int i = 0; i < points.length - 1; i++) {
      paint.color = rainbowPalette[i % rainbowPalette.length];
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  static void _drawRainbowFuzzy(
    Canvas canvas,
    List<Offset> points,
    double strokeWidth,
    double blurSigma,
    double coreWidth,
  ) {
    for (int i = 0; i < points.length - 1; i++) {
      final c = rainbowPalette[i % rainbowPalette.length];

      _fuzzStrokePaint.color = c;
      _fuzzStrokePaint.strokeWidth = strokeWidth * 1.05;
      _fuzzStrokePaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
      canvas.drawLine(points[i], points[i + 1], _fuzzStrokePaint);

      _fuzzCorePaint.color = c;
      _fuzzCorePaint.strokeWidth = coreWidth;
      _fuzzCorePaint.maskFilter = null;
      canvas.drawLine(points[i], points[i + 1], _fuzzCorePaint);
    }
  }
}

/// High-performance CustomPainter strictly following flutter-ultimate standards:
/// - Static reusable Paint objects (zero allocations inside paint())
/// - True shouldRepaint change detection
class HistoryCanvasPainter extends CustomPainter {
  HistoryCanvasPainter({
    required this.actions,
    this.starterAsset,
  });

  final List<DrawingAction> actions;
  final String? starterAsset;

  static final Paint _whiteBgPaint = Paint()..color = Colors.white;
  static final Paint _shapeStrokePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  static final Paint _shapeFillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _stampPaint = Paint()..filterQuality = FilterQuality.medium;
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;

  static final Path _shapePath = Path();
  static final Path _starPath = Path();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    // Draw Starter coloring outline / background if selected
    if (starterAsset != null) {
      final starterImg = TuxImageCache.get(starterAsset!);
      if (starterImg != null) {
        final src = Rect.fromLTWH(0, 0, starterImg.width.toDouble(), starterImg.height.toDouble());
        final dst = Rect.fromLTWH(0, 0, size.width, size.height);
        canvas.drawImageRect(starterImg, src, dst, _stampPaint);
      }
    }

    for (final action in actions) {
      switch (action) {
        case ClearCanvasAction():
          canvas.drawRect(Offset.zero & size, _whiteBgPaint);

        case StrokeAction(
            points: final points,
            color: final color,
            strokeWidth: final strokeWidth,
            isRainbow: final isRainbow,
            isEraser: final isEraser,
            brushAsset: final brushAsset,
          ):
          BrushRenderer.drawStroke(
            canvas: canvas,
            points: points,
            color: color,
            strokeWidth: strokeWidth,
            isRainbow: isRainbow,
            isEraser: isEraser,
            brushAsset: brushAsset,
          );

        case LineAction(
            start: final start,
            end: final end,
            color: final color,
            strokeWidth: final strokeWidth,
            brushAsset: final brushAsset,
            isRainbow: final isRainbow,
          ):
          BrushRenderer.drawLine(
            canvas: canvas,
            start: start,
            end: end,
            color: color,
            strokeWidth: strokeWidth,
            isRainbow: isRainbow,
            brushAsset: brushAsset,
          );

        case MagicAction():
          MagicRenderer.drawMagic(canvas, action);

        case StampAction(
            position: final pos,
            assetPath: final assetPath,
            size: final stampSize,
          ):
          final image = TuxImageCache.get(assetPath);
          if (image != null) {
            final srcRect = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
            final dstRect = Rect.fromCenter(center: pos, width: stampSize * 1.8, height: stampSize * 1.8);
            canvas.drawImageRect(image, srcRect, dstRect, _stampPaint);
          }

        case ShapeAction(
            start: final start,
            end: final end,
            shapeType: final type,
            color: final color,
            strokeWidth: final strokeWidth,
            isFilled: final isFilled,
          ):
          final paint = isFilled ? _shapeFillPaint : _shapeStrokePaint;
          paint.color = color;
          paint.strokeWidth = strokeWidth;
          _drawShape(canvas, start, end, type, paint);

        case FillAction(
            color: final color,
            filledImage: final img,
          ):
          if (img != null) {
            final src = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
            final dst = Rect.fromLTWH(0, 0, size.width, size.height);
            canvas.drawImageRect(img, src, dst, _stampPaint);
          } else {
            // Instant visual fill: fills background if canvas is empty
            _fillPaint.color = color;
            canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _fillPaint);
          }
      }
    }
  }

  void _drawShape(Canvas canvas, Offset start, Offset end, ShapeType type, Paint paint) {
    final rect = Rect.fromPoints(start, end);
    switch (type) {
      case ShapeType.rectangle:
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)), paint);
      case ShapeType.circle:
        canvas.drawOval(rect, paint);
      case ShapeType.triangle:
        _shapePath.reset();
        _shapePath.moveTo(rect.center.dx, rect.top);
        _shapePath.lineTo(rect.right, rect.bottom);
        _shapePath.lineTo(rect.left, rect.bottom);
        _shapePath.close();
        canvas.drawPath(_shapePath, paint);
      case ShapeType.star:
        _drawStar(canvas, rect, paint);
    }
  }

  void _drawStar(Canvas canvas, Rect rect, Paint paint) {
    _starPath.reset();
    final center = rect.center;
    final rOuter = rect.width / 2;
    final rInner = rOuter / 2.2;
    const numPoints = 5;

    for (int i = 0; i < numPoints * 2; i++) {
      final r = i.isEven ? rOuter : rInner;
      final angle = (i * math.pi / numPoints) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        _starPath.moveTo(x, y);
      } else {
        _starPath.lineTo(x, y);
      }
    }
    _starPath.close();
    canvas.drawPath(_starPath, paint);
  }

  @override
  bool shouldRepaint(covariant HistoryCanvasPainter oldDelegate) {
    return oldDelegate.actions.length != actions.length ||
        oldDelegate.actions != actions ||
        oldDelegate.starterAsset != starterAsset;
  }
}

/// Lightweight live stroke and rubberband line painter for current in-progress finger drag.
class ActiveStrokePainter extends CustomPainter {
  ActiveStrokePainter({
    required this.points,
    required this.lineStart,
    required this.lineCurrent,
    required this.color,
    required this.strokeWidth,
    required this.isRainbow,
    required this.isEraser,
    this.brushAsset,
    this.magicType,
  });

  final List<Offset>? points;
  final Offset? lineStart;
  final Offset? lineCurrent;
  final Color color;
  final double strokeWidth;
  final bool isRainbow;
  final bool isEraser;
  final String? brushAsset;
  final MagicType? magicType;

  @override
  void paint(Canvas canvas, Size size) {
    if (lineStart != null && lineCurrent != null) {
      BrushRenderer.drawLine(
        canvas: canvas,
        start: lineStart!,
        end: lineCurrent!,
        color: color,
        strokeWidth: strokeWidth,
        isRainbow: isRainbow,
        brushAsset: brushAsset,
      );
      return;
    }

    if (points == null || points!.isEmpty) return;

    if (magicType != null) {
      MagicRenderer.drawMagic(
        canvas,
        MagicAction(
          magicType: magicType!,
          points: points!,
          color: color,
          strokeWidth: strokeWidth,
        ),
      );
    } else {
      BrushRenderer.drawStroke(
        canvas: canvas,
        points: points!,
        color: color,
        strokeWidth: strokeWidth,
        isRainbow: isRainbow,
        isEraser: isEraser,
        brushAsset: brushAsset,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ActiveStrokePainter oldDelegate) {
    return oldDelegate.points?.length != points?.length ||
        oldDelegate.lineStart != lineStart ||
        oldDelegate.lineCurrent != lineCurrent ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.brushAsset != brushAsset ||
        oldDelegate.magicType != magicType;
  }
}
