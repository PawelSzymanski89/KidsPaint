import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../controllers/drawing_controller.dart';
import '../../painters/canvas_painter.dart';
import '../../services/flood_fill.dart';

class DrawingCanvas extends StatefulWidget {
  const DrawingCanvas({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  final GlobalKey _canvasRepaintBoundaryKey = GlobalKey();
  Offset? _shapeStart;
  bool _isProcessingFill = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Listener(
            onPointerDown: (e) => _onPointerDown(e.localPosition, constraints.biggest),
            onPointerMove: (e) => _onPointerMove(e.localPosition),
            onPointerUp: (e) => _onPointerUp(e.localPosition),
            onPointerCancel: (e) => _onPointerCancel(),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // 1. History Layer (Isolated RepaintBoundary: repaints ONLY on undo/redo/commit)
                RepaintBoundary(
                  key: _canvasRepaintBoundaryKey,
                  child: CustomPaint(
                    painter: HistoryCanvasPainter(
                      actions: widget.controller.history,
                      starterAsset: widget.controller.selectedStarterAsset,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),

                // 2. Active Stroke & Rubberband Layer (smooth 120 FPS without repainting history)
                RepaintBoundary(
                  child: CustomPaint(
                    painter: ActiveStrokePainter(
                      points: widget.controller.activePoints,
                      lineStart: widget.controller.lineStart,
                      lineCurrent: widget.controller.lineCurrent,
                      color: widget.controller.currentColor,
                      strokeWidth: widget.controller.currentStrokeSize,
                      isRainbow: widget.controller.isRainbow,
                      isEraser: widget.controller.currentTool == KidsTool.eraser,
                      brushAsset: widget.controller.currentTool == KidsTool.eraser
                          ? null
                          : widget.controller.selectedBrushAsset,
                      magicType: widget.controller.currentTool == KidsTool.magic
                          ? widget.controller.selectedMagic
                          : null,
                    ),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleFloodFill(Offset localPos, Size size) async {
    if (_isProcessingFill) return;
    _isProcessingFill = true;

    try {
      final boundary = _canvasRepaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        widget.controller.addFill(localPos);
        return;
      }

      // Capture current raster image of canvas with its natural pixel ratio
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData();
      if (byteData == null) {
        widget.controller.addFill(localPos);
        return;
      }

      final pixels = byteData.buffer.asUint8List();
      final width = image.width;
      final height = image.height;

      final success = FloodFillService.floodFill(
        pixels: pixels,
        width: width,
        height: height,
        startX: (localPos.dx * pixelRatio).round().clamp(0, width - 1),
        startY: (localPos.dy * pixelRatio).round().clamp(0, height - 1),
        fillColor: widget.controller.currentColor,
        tolerance: 40,
      );

      if (success) {
        final newUiImage = await FloodFillService.createUiImageFromPixels(pixels, width, height);
        widget.controller.addFill(localPos, filledImage: newUiImage);
      }
    } catch (e) {
      debugPrint('Flood fill error: $e');
      widget.controller.addFill(localPos);
    } finally {
      _isProcessingFill = false;
    }
  }

  void _onPointerDown(Offset localPos, Size size) {
    switch (widget.controller.currentTool) {
      case KidsTool.brush:
      case KidsTool.eraser:
      case KidsTool.magic:
        widget.controller.startStroke(localPos);
      case KidsTool.lines:
        widget.controller.startLine(localPos);
      case KidsTool.stamps:
        widget.controller.addStamp(localPos);
      case KidsTool.fill:
        _handleFloodFill(localPos, size);
      case KidsTool.shapes:
        _shapeStart = localPos;
      case KidsTool.coloring:
        break;
    }
  }

  void _onPointerMove(Offset localPos) {
    switch (widget.controller.currentTool) {
      case KidsTool.brush:
      case KidsTool.eraser:
      case KidsTool.magic:
        widget.controller.updateStroke(localPos);
      case KidsTool.lines:
        widget.controller.updateLine(localPos);
      case KidsTool.stamps:
      case KidsTool.fill:
      case KidsTool.shapes:
      case KidsTool.coloring:
        break;
    }
  }

  void _onPointerUp(Offset localPos) {
    switch (widget.controller.currentTool) {
      case KidsTool.brush:
      case KidsTool.eraser:
      case KidsTool.magic:
        widget.controller.endStroke();
      case KidsTool.lines:
        widget.controller.endLine();
      case KidsTool.stamps:
      case KidsTool.fill:
      case KidsTool.coloring:
        break;
      case KidsTool.shapes:
        if (_shapeStart != null) {
          widget.controller.addShape(_shapeStart!, localPos);
          _shapeStart = null;
        }
    }
  }

  void _onPointerCancel() {
    _shapeStart = null;
    widget.controller.endStroke();
  }
}
