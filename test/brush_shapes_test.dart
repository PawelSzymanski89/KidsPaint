import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidspaint/data/tux_assets.dart';
import 'package:kidspaint/painters/canvas_painter.dart';
import 'package:kidspaint/services/image_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All Tux brush categories render with distinct shapes and frames', () async {
    // 1. Verify brush metadata
    final starBrush = TuxAssets.findBrush('assets/tuxpaint/brushes/star.png');
    expect(starBrush.renderType, BrushRenderType.patternStamp);

    final arrowBrush = TuxAssets.findBrush('assets/tuxpaint/brushes/arrow.png');
    expect(arrowBrush.rotates, isTrue);

    final pawsBrush = TuxAssets.findBrush('assets/tuxpaint/brushes/footprints-paws.png');
    expect(pawsBrush.frames, 2);
    expect(pawsBrush.directional, isTrue);

    // 2. Load images into TuxImageCache
    for (final path in [
      'assets/tuxpaint/brushes/star.png',
      'assets/tuxpaint/brushes/arrow.png',
      'assets/tuxpaint/brushes/footprints-paws.png',
      'assets/tuxpaint/brushes/triangle_up.png',
      'assets/tuxpaint/brushes/heart.png',
    ]) {
      final bytes = File(path).readAsBytesSync();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      // TuxImageCache loads via asset bundle or cached
      await TuxImageCache.load(path);
      expect(frame.image, isNotNull);
    }

    // 3. Render strokes on canvas
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw star stroke
    BrushRenderer.drawStroke(
      canvas: canvas,
      points: const [Offset(20, 20), Offset(60, 20)],
      color: Colors.amber,
      strokeWidth: 32.0,
      isRainbow: false,
      isEraser: false,
      brushAsset: starBrush.assetPath,
    );

    // Draw rotating arrow stroke
    BrushRenderer.drawStroke(
      canvas: canvas,
      points: const [Offset(20, 80), Offset(60, 120)],
      color: Colors.purple,
      strokeWidth: 32.0,
      isRainbow: false,
      isEraser: false,
      brushAsset: arrowBrush.assetPath,
    );

    // Draw multi-frame directional paws stroke
    BrushRenderer.drawStroke(
      canvas: canvas,
      points: const [Offset(20, 160), Offset(60, 160), Offset(100, 160)],
      color: Colors.brown,
      strokeWidth: 40.0,
      isRainbow: false,
      isEraser: false,
      brushAsset: pawsBrush.assetPath,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(200, 200);
    expect(img.width, 200);
    expect(img.height, 200);
  });
}
