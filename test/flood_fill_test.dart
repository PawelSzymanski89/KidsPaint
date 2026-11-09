import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidspaint/services/flood_fill.dart';

void main() {
  test('FloodFillService fills an enclosed rectangle without leaking outside', () {
    const width = 10;
    const height = 10;
    // 10x10 RGBA image initialized to white (255, 255, 255, 255)
    final pixels = Uint8List(width * height * 4);
    for (int i = 0; i < pixels.length; i += 4) {
      pixels[i] = 255;
      pixels[i + 1] = 255;
      pixels[i + 2] = 255;
      pixels[i + 3] = 255;
    }

    // Draw a black border around the box [2..6, 2..6]
    void setBlack(int x, int y) {
      final idx = (y * width + x) * 4;
      pixels[idx] = 0;
      pixels[idx + 1] = 0;
      pixels[idx + 2] = 0;
      pixels[idx + 3] = 255;
    }

    for (int x = 2; x <= 6; x++) {
      setBlack(x, 2);
      setBlack(x, 6);
    }
    for (int y = 2; y <= 6; y++) {
      setBlack(2, y);
      setBlack(6, y);
    }

    // Flood fill inside the box at (4, 4) with Red
    final filled = FloodFillService.floodFill(
      pixels: pixels,
      width: width,
      height: height,
      startX: 4,
      startY: 4,
      fillColor: const Color(0xFFFF0000),
      tolerance: 10,
    );

    expect(filled, isTrue);

    // Verify inside is Red (255, 0, 0, 255)
    const insideIdx = (4 * width + 4) * 4;
    expect(pixels[insideIdx], 255);
    expect(pixels[insideIdx + 1], 0);
    expect(pixels[insideIdx + 2], 0);

    // Verify border remains Black (0, 0, 0, 255)
    const borderIdx = (2 * width + 4) * 4;
    expect(pixels[borderIdx], 0);
    expect(pixels[borderIdx + 1], 0);
    expect(pixels[borderIdx + 2], 0);

    // Verify outside remains White (255, 255, 255, 255)
    const outsideIdx = (0 * width + 0) * 4;
    expect(pixels[outsideIdx], 255);
    expect(pixels[outsideIdx + 1], 255);
    expect(pixels[outsideIdx + 2], 255);
  });
}
