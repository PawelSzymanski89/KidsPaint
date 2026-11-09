import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidspaint/controllers/drawing_controller.dart';
import 'package:kidspaint/main.dart';
import 'package:kidspaint/services/i18n.dart';

void main() {
  testWidgets('KidsPaint app launches and shows tools and color dock', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const KidsPaintApp());

    // Verify key tools are displayed
    expect(find.text('Pędzel'), findsOneWidget);
    expect(find.text('Stemple'), findsOneWidget);
    expect(find.text('Magia'), findsOneWidget);
    expect(find.text('Gumka'), findsOneWidget);

    // Verify undo button exists
    expect(find.text('Oops!'), findsOneWidget);

    // Verify 10 brush sizes indicator
    expect(find.text(I18n.instance.brushSizesScale), findsOneWidget);
  });

  test('DrawingController infinite undo and redo logic', () {
    final controller = DrawingController();

    expect(controller.canUndo, false);
    expect(controller.undoCount, 0);

    // Simulate 50 strokes
    for (int i = 0; i < 50; i++) {
      controller.startStroke(const Offset(10, 10));
      controller.updateStroke(const Offset(20, 20));
      controller.endStroke();
    }

    expect(controller.undoCount, 50);
    expect(controller.canUndo, true);

    // Undo 30 times
    for (int i = 0; i < 30; i++) {
      controller.undo();
    }

    expect(controller.undoCount, 20);
    expect(controller.redoCount, 30);
    expect(controller.canRedo, true);

    // Redo 10 times
    for (int i = 0; i < 10; i++) {
      controller.redo();
    }

    expect(controller.undoCount, 30);
    expect(controller.redoCount, 20);
  });
}
