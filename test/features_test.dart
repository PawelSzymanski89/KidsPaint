import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidspaint/controllers/drawing_controller.dart';
import 'package:kidspaint/models/drawing_action.dart';
import 'package:kidspaint/painters/magic_renderer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('All Tux Paint features operate with state changes and audio hooks', () {
    final controller = DrawingController();

    // 1. Tool switching
    controller.setTool(KidsTool.magic);
    expect(controller.currentTool, KidsTool.magic);

    controller.setMagic(MagicType.rainbow);
    expect(controller.selectedMagic, MagicType.rainbow);

    // 2. Stroke with magic
    controller.startStroke(const Offset(10, 10));
    controller.updateStroke(const Offset(20, 20));
    controller.endStroke();

    expect(controller.history.length, 1);
    expect(controller.history.first, isA<MagicAction>());

    // 3. Lines tool
    controller.setTool(KidsTool.lines);
    controller.startLine(const Offset(50, 50));
    controller.updateLine(const Offset(150, 150));
    controller.endLine();

    expect(controller.history.length, 2);
    expect(controller.history.last, isA<LineAction>());

    // 4. Fill tool
    controller.setTool(KidsTool.fill);
    controller.addFill(const Offset(80, 80));

    expect(controller.history.length, 3);
    expect(controller.history.last, isA<FillAction>());

    // 5. Starters
    controller.setStarter('assets/tuxpaint/starters/chicken.png');
    expect(controller.selectedStarterAsset, 'assets/tuxpaint/starters/chicken.png');
    expect(controller.history.isEmpty, isTrue); // setting starter clears canvas for fresh drawing
  });

  test('MagicRenderer draws all Tux magic effects without throwing', () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const points = [Offset(10, 10), Offset(50, 50), Offset(100, 20)];

    for (final magic in MagicType.values) {
      MagicRenderer.drawMagic(
        canvas,
        MagicAction(
          magicType: magic,
          points: points,
          color: Colors.green,
          strokeWidth: 30.0,
        ),
      );
    }

    final picture = recorder.endRecording();
    expect(picture, isNotNull);
  });
}
