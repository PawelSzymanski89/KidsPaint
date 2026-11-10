import 'package:flutter/material.dart';
import '../controllers/drawing_controller.dart';
import '../services/image_loader.dart';
import 'widgets/color_palette_dock.dart';
import 'widgets/drawing_canvas.dart';
import 'widgets/kids_top_bar.dart';
import 'widgets/sub_options_shelf.dart';
import 'widgets/tool_sidebar.dart';
import 'widgets/tux_bottom_bar.dart';

class KidsPaintScreen extends StatefulWidget {
  const KidsPaintScreen({super.key});

  @override
  State<KidsPaintScreen> createState() => _KidsPaintScreenState();
}

class _KidsPaintScreenState extends State<KidsPaintScreen> {
  late final DrawingController _controller;
  DrawingController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _controller = DrawingController();
    TuxImageCache.load('assets/tuxpaint/stamps/tux/tux-yes2.png');
    TuxImageCache.load('assets/tuxpaint/stamps/tux/tux-yay2.png');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          body: Column(
            children: <Widget>[
              // Top Bar with Fullscreen/Zoom, Title, Window Dragging & State Persistence
              KidsTopBar(controller: _controller),

              Expanded(
                child: Row(
                  children: <Widget>[
                    // Left: Direct Tools Sidebar
                    ToolSidebar(controller: _controller),

                    // Center: Drawing Canvas + Contextual Shelf + Bottom Palette Dock + Tux Status Bar
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          // Contextual sub-options shelf (authentic brushes, stamps, shapes, magic, starters)
                          SubOptionsShelf(controller: _controller),

                          // Canvas
                          Expanded(
                            child: DrawingCanvas(controller: _controller),
                          ),

                          // Tux penguin assistant speech bubble
                          TuxBottomBar(controller: _controller),

                          // Bottom 18-color palette + 10 brush sizes + undo/redo/clear
                          ColorPaletteDock(controller: _controller),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
