import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidspaint/controllers/drawing_controller.dart';
import 'package:kidspaint/data/tux_assets.dart';
import 'package:kidspaint/models/drawing_action.dart';
import 'package:kidspaint/painters/canvas_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('BrushRenderer properly selects and renders fuzzy round brush', () {
    final fuzzyBrush = TuxAssets.findBrush('assets/tuxpaint/brushes/aa_round_fuzz.png');
    expect(fuzzyBrush.renderType, BrushRenderType.fuzzyRound);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    // Render fuzzy brush stroke
    BrushRenderer.drawStroke(
      canvas: canvas,
      points: const [Offset(50, 50), Offset(100, 100), Offset(150, 120)],
      color: Colors.blue,
      strokeWidth: 40.0,
      isRainbow: false,
      isEraser: false,
      brushAsset: fuzzyBrush.assetPath,
    );

    final picture = recorder.endRecording();
    expect(picture, isNotNull);
  });

  test('BrushRenderer properly renders square and seeThru brushes', () {
    final squareFuzz = TuxAssets.findBrush('assets/tuxpaint/brushes/square_fuzz.png');
    expect(squareFuzz.renderType, BrushRenderType.fuzzySquare);

    final seeThru = TuxAssets.findBrush('assets/tuxpaint/brushes/aa_round_seethru.png');
    expect(seeThru.renderType, BrushRenderType.seeThru);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    BrushRenderer.drawStroke(
      canvas: canvas,
      points: const [Offset(10, 10), Offset(30, 30)],
      color: Colors.red,
      strokeWidth: 20.0,
      isRainbow: false,
      isEraser: false,
      brushAsset: squareFuzz.assetPath,
    );

    BrushRenderer.drawStroke(
      canvas: canvas,
      points: const [Offset(40, 40), Offset(60, 60)],
      color: Colors.green,
      strokeWidth: 30.0,
      isRainbow: false,
      isEraser: false,
      brushAsset: seeThru.assetPath,
    );

    final picture = recorder.endRecording();
    expect(picture, isNotNull);
  });

  test('StrokeAction records brushAsset in DrawingController', () {
    final controller = DrawingController();
    controller.setTool(KidsTool.brush);
    controller.setBrush('assets/tuxpaint/brushes/aa_round_fuzz.png');

    controller.startStroke(const Offset(10, 10));
    controller.updateStroke(const Offset(20, 20));
    controller.endStroke();

    expect(controller.history.length, 1);
    final action = controller.history.first as StrokeAction;
    expect(action.brushAsset, 'assets/tuxpaint/brushes/aa_round_fuzz.png');
  });
}
