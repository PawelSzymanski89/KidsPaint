import 'dart:ui' show Offset, Color;
import 'dart:ui' as ui;

/// Dart 3 Sealed Hierarchy for all drawing operations in KidsPaint.
/// Enables exhaustive pattern matching and compact memory footprints.
sealed class DrawingAction {
  const DrawingAction();
}

/// Freehand continuous stroke (Paint / Eraser / Rainbow).
final class StrokeAction extends DrawingAction {
  const StrokeAction({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isRainbow = false,
    this.isEraser = false,
    this.brushAsset,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isRainbow;
  final bool isEraser;
  final String? brushAsset;
}

/// Connected straight line segment drawn with selected brush.
final class LineAction extends DrawingAction {
  const LineAction({
    required this.start,
    required this.end,
    required this.color,
    required this.strokeWidth,
    this.brushAsset,
    this.isRainbow = false,
  });

  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;
  final String? brushAsset;
  final bool isRainbow;
}

/// Stamp placement with authentic Tux Paint image.
final class StampAction extends DrawingAction {
  const StampAction({
    required this.position,
    required this.assetPath,
    required this.size,
  });

  final Offset position;
  final String assetPath;
  final double size;
}

/// Geometric shape action (Circle, Rectangle, Star, etc.).
final class ShapeAction extends DrawingAction {
  const ShapeAction({
    required this.start,
    required this.end,
    required this.shapeType,
    required this.color,
    required this.strokeWidth,
    required this.isFilled,
  });

  final Offset start;
  final Offset end;
  final ShapeType shapeType;
  final Color color;
  final double strokeWidth;
  final bool isFilled;
}

enum ShapeType {
  circle,
  rectangle,
  triangle,
  star,
}

/// Magic Tool action representing special procedural effects (Grass, Rainbow, Bricks, Chalk, Blur, Rails, etc.).
final class MagicAction extends DrawingAction {
  const MagicAction({
    required this.magicType,
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isLarge = false,
  });

  final MagicType magicType;
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isLarge;
}

enum MagicType {
  grass,
  rainbow,
  realRainbow,
  bricks,
  chalk,
  blur,
  rails,
  foam,
  confetti,
  flower,
}

/// Flood Fill action filling a contiguous color region with a raster bitmap snapshot.
final class FillAction extends DrawingAction {
  const FillAction({
    required this.position,
    required this.color,
    this.filledImage,
  });

  final Offset position;
  final Color color;
  final ui.Image? filledImage;
}

/// Full canvas clear action that can be undone.
final class ClearCanvasAction extends DrawingAction {
  const ClearCanvasAction();
}
