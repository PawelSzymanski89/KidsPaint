import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// High-performance span-based flood fill algorithm (matching Tux Paint & MS Paint).
class FloodFillService {
  FloodFillService._();

  /// Performs a 4-way span flood fill on an RGBA byte buffer.
  /// Modifies [pixels] in-place.
  static bool floodFill({
    required Uint8List pixels,
    required int width,
    required int height,
    required int startX,
    required int startY,
    required Color fillColor,
    int tolerance = 32,
  }) {
    if (startX < 0 || startX >= width || startY < 0 || startY >= height) {
      return false;
    }

    final int startIndex = (startY * width + startX) * 4;
    final int targetR = pixels[startIndex];
    final int targetG = pixels[startIndex + 1];
    final int targetB = pixels[startIndex + 2];
    final int targetA = pixels[startIndex + 3];

    final int fillR = (fillColor.r * 255).round().clamp(0, 255);
    final int fillG = (fillColor.g * 255).round().clamp(0, 255);
    final int fillB = (fillColor.b * 255).round().clamp(0, 255);
    final int fillA = (fillColor.a * 255).round().clamp(0, 255);

    // If already the same color, no-op
    if (_colorsMatch(targetR, targetG, targetB, targetA, fillR, fillG, fillB, fillA, 0)) {
      return false;
    }

    bool matchesTarget(int x, int y) {
      final int idx = (y * width + x) * 4;
      return _colorsMatch(
        pixels[idx],
        pixels[idx + 1],
        pixels[idx + 2],
        pixels[idx + 3],
        targetR,
        targetG,
        targetB,
        targetA,
        tolerance,
      );
    }

    void setPixel(int x, int y) {
      final int idx = (y * width + x) * 4;
      pixels[idx] = fillR;
      pixels[idx + 1] = fillG;
      pixels[idx + 2] = fillB;
      pixels[idx + 3] = fillA;
    }

    // Span-based scanline queue for 60 FPS flood fill performance
    final queue = Queue<({int x1, int x2, int y, int dy})>();

    // Initial span
    int x1 = startX;
    while (x1 > 0 && matchesTarget(x1 - 1, startY)) {
      x1--;
    }
    int x2 = startX;
    while (x2 < width - 1 && matchesTarget(x2 + 1, startY)) {
      x2++;
    }

    for (int x = x1; x <= x2; x++) {
      setPixel(x, startY);
    }

    if (startY > 0) queue.add((x1: x1, x2: x2, y: startY, dy: -1));
    if (startY < height - 1) queue.add((x1: x1, x2: x2, y: startY, dy: 1));

    while (queue.isNotEmpty) {
      final span = queue.removeFirst();
      final targetY = span.y + span.dy;
      if (targetY < 0 || targetY >= height) continue;

      int x = span.x1;
      while (x <= span.x2) {
        if (matchesTarget(x, targetY)) {
          int startSpan = x;
          while (startSpan > 0 && matchesTarget(startSpan - 1, targetY)) {
            startSpan--;
          }
          int endSpan = x;
          while (endSpan < width - 1 && matchesTarget(endSpan + 1, targetY)) {
            endSpan++;
          }

          for (int i = startSpan; i <= endSpan; i++) {
            setPixel(i, targetY);
          }

          if (targetY + span.dy >= 0 && targetY + span.dy < height) {
            queue.add((x1: startSpan, x2: endSpan, y: targetY, dy: span.dy));
          }
          if (startSpan < span.x1 || endSpan > span.x2) {
            // Check reverse direction on protruding spans
            if (targetY - span.dy >= 0 && targetY - span.dy < height) {
              queue.add((x1: startSpan, x2: endSpan, y: targetY, dy: -span.dy));
            }
          }

          x = endSpan + 1;
        } else {
          x++;
        }
      }
    }

    return true;
  }

  static bool _colorsMatch(
    int r1,
    int g1,
    int b1,
    int a1,
    int r2,
    int g2,
    int b2,
    int a2,
    int tol,
  ) {
    if (tol == 0) {
      return r1 == r2 && g1 == g2 && b1 == b2 && a1 == a2;
    }
    final int dr = (r1 - r2).abs();
    final int dg = (g1 - g2).abs();
    final int db = (b1 - b2).abs();
    final int da = (a1 - a2).abs();
    return dr <= tol && dg <= tol && db <= tol && da <= tol;
  }

  /// Converts modified raw RGBA pixels back into a [ui.Image].
  static Future<ui.Image> createUiImageFromPixels(
    Uint8List pixels,
    int width,
    int height,
  ) async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: width,
      height: height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}
