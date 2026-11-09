import 'package:flutter/material.dart';
import '../../controllers/drawing_controller.dart';
import '../../services/i18n.dart';

class ColorPaletteDock extends StatelessWidget {
  const ColorPaletteDock({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  static const List<Color> palette18 = <Color>[
    Color(0xFFE63946), // Red
    Color(0xFFFF5A5F), // Coral
    Color(0xFFFF9F1C), // Orange
    Color(0xFFFFD166), // Sunny Yellow
    Color(0xFFD4E09B), // Lime
    Color(0xFF06D6A0), // Emerald Green
    Color(0xFF2A9D8F), // Teal
    Color(0xFF118AB2), // Sky Blue
    Color(0xFF0077B6), // Ocean Blue
    Color(0xFF1D3557), // Deep Navy
    Color(0xFF7B2CBF), // Purple
    Color(0xFFB5179E), // Magenta
    Color(0xFFFF70A6), // Pink
    Color(0xFFFFCAD4), // Light Pink
    Color(0xFFF4A261), // Peach Beige
    Color(0xFF6F4E37), // Chocolate Brown
    Color(0xFF222222), // Charcoal Black
    Color(0xFFFFFFFF), // White
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 3),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: <Widget>[
              // Dual-row 18-color grid
              Expanded(
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: palette18.length + 1, // +1 for Rainbow
                  itemBuilder: (context, index) {
                    if (index == palette18.length) {
                      return _RainbowBubble(
                        isSelected: controller.isRainbow,
                        onTap: () => controller.setRainbow(true),
                      );
                    }
                    final color = palette18[index];
                    final isSelected = !controller.isRainbow && controller.currentColor == color;
                    return _ColorBubble(
                      color: color,
                      isSelected: isSelected,
                      onTap: () => controller.setColor(color),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Size selector gauge (10 sizes: 4px to 100px)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 4),
                      child: Text(
                        I18n.instance.brushSizesScale,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const <double>[4.0, 8.0, 12.0, 18.0, 26.0, 36.0, 48.0, 62.0, 80.0, 100.0]
                          .map((size) {
                        final isSelected = (controller.currentStrokeSize - size).abs() < 2.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.5),
                          child: _SizeBubble(
                            size: size,
                            isSelected: isSelected,
                            onTap: () => controller.setStrokeSize(size),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Unlimited Undo & Redo group
              Row(
                children: <Widget>[
                  Semantics(
                    button: true,
                    label: 'Cofnij ostatnie pociągnięcie, kroków: ${controller.undoCount}',
                    child: GestureDetector(
                      onTap: controller.canUndo ? controller.undo : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: controller.canUndo ? 1.0 : 0.35,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF59E0B), width: 3),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x33F59E0B),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text('↩️', style: TextStyle(fontSize: 22)),
                              Text(
                                controller.undoCount > 0 ? '${controller.undoCount}' : 'Oops!',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  Semantics(
                    button: true,
                    label: 'Ponów',
                    child: GestureDetector(
                      onTap: controller.canRedo ? controller.redo : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 100),
                        opacity: controller.canRedo ? 1.0 : 0.35,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                          ),
                          child: const Center(
                            child: Text('↪️', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Clear trash icon
                  Semantics(
                    button: true,
                    label: 'Nowa czysta kartka',
                    child: GestureDetector(
                      onTap: controller.canUndo ? controller.clearCanvas : null,
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5E5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFF5A5F), width: 2),
                        ),
                        child: const Center(
                          child: Text('🗑️', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorBubble extends StatelessWidget {
  const _ColorBubble({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: isSelected ? 1.2 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? const Color(0xFF0F172A) : (color == Colors.white ? const Color(0xFFCBD5E1) : Colors.white),
              width: isSelected ? 3.5 : 2.5,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RainbowBubble extends StatelessWidget {
  const _RainbowBubble({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: isSelected ? 1.2 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(
              colors: <Color>[
                Color(0xFFFF5A5F),
                Color(0xFFFFB703),
                Color(0xFF06D6A0),
                Color(0xFF118AB2),
                Color(0xFF7B2CBF),
                Color(0xFFFF5A5F),
              ],
            ),
            border: Border.all(
              color: isSelected ? const Color(0xFF0F172A) : Colors.white,
              width: isSelected ? 3.5 : 2.5,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SizeBubble extends StatelessWidget {
  const _SizeBubble({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  final double size;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Map size (4..100) to visual diameter (6..26)
    final double visualDiameter = 6.0 + (size - 4.0) * (20.0 / 96.0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 30,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFE5E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5A5F) : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: visualDiameter,
          height: visualDiameter,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFF5A5F) : const Color(0xFF475569),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
