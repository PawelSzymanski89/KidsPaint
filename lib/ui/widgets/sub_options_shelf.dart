import 'package:flutter/material.dart';
import '../../controllers/drawing_controller.dart';
import '../../data/tux_assets.dart';
import '../../models/drawing_action.dart';
import '../../services/i18n.dart';
import '../../services/image_loader.dart';

class SubOptionsShelf extends StatelessWidget {
  const SubOptionsShelf({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.currentTool == KidsTool.stamps) {
      return StampsShelf(controller: controller);
    }

    if (controller.currentTool == KidsTool.brush || controller.currentTool == KidsTool.lines) {
      return BrushesShelf(
        controller: controller,
        title: controller.currentTool == KidsTool.lines ? I18n.instance.lineBrush : I18n.instance.brushShape,
      );
    }

    if (controller.currentTool == KidsTool.shapes) {
      return ShapesShelf(controller: controller);
    }

    if (controller.currentTool == KidsTool.magic) {
      return MagicShelf(controller: controller);
    }

    if (controller.currentTool == KidsTool.coloring) {
      return StartersShelf(controller: controller);
    }

    return const SizedBox.shrink();
  }
}

class MagicShelf extends StatelessWidget {
  const MagicShelf({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  static const List<({MagicType type, String icon, String name})> magicTools = [
    (type: MagicType.grass, icon: '🌿', name: 'Trawa'),
    (type: MagicType.rainbow, icon: '🌈', name: 'Tęcza'),
    (type: MagicType.realRainbow, icon: '🌦️', name: 'Łuk tęczy'),
    (type: MagicType.bricks, icon: '🧱', name: 'Cegły'),
    (type: MagicType.chalk, icon: '🖍️', name: 'Kreda'),
    (type: MagicType.blur, icon: '🌫️', name: 'Rozmycie'),
    (type: MagicType.rails, icon: '🛤️', name: 'Tory'),
    (type: MagicType.foam, icon: '🫧', name: 'Piana'),
    (type: MagicType.confetti, icon: '🎊', name: 'Konfetti'),
    (type: MagicType.flower, icon: '🌸', name: 'Kwiaty'),
  ];

  String _magicName(MagicType type) {
    return switch (type) {
      MagicType.grass => I18n.instance.magicGrass,
      MagicType.rainbow => I18n.instance.magicRainbow,
      MagicType.realRainbow => I18n.instance.magicRealRainbow,
      MagicType.bricks => I18n.instance.magicBricks,
      MagicType.chalk => I18n.instance.magicChalk,
      MagicType.blur => I18n.instance.magicBlur,
      MagicType.rails => I18n.instance.magicRails,
      MagicType.foam => I18n.instance.magicFoam,
      MagicType.confetti => I18n.instance.magicConfetti,
      MagicType.flower => I18n.instance.magicFlower,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 2),
      ),
      child: Row(
        children: <Widget>[
          Text(I18n.instance.magicEffect, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF6B21A8))),
          const SizedBox(width: 10),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: magicTools.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = magicTools[index];
                final isSelected = controller.selectedMagic == item.type;

                return GestureDetector(
                  onTap: () => controller.setMagic(item.type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFC084FC) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF9333EA) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? const <BoxShadow>[
                              BoxShadow(color: Color(0x339333EA), blurRadius: 6, offset: Offset(0, 2))
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text(
                          _magicName(item.type),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StartersShelf extends StatelessWidget {
  const StartersShelf({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    const starters = TuxAssets.starters;

    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
      ),
      child: Row(
        children: <Widget>[
          Text(I18n.instance.coloringPages, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
          const SizedBox(width: 8),
          // Clear starter button (blank paper)
          GestureDetector(
            onTap: () => controller.setStarter(null),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: controller.selectedStarterAsset == null ? const Color(0xFF3B82F6) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.selectedStarterAsset == null ? const Color(0xFF1D4ED8) : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: Text(
                I18n.instance.blankCanvas,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: controller.selectedStarterAsset == null ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 14, color: Color(0xFFCBD5E1)),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: starters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final starter = starters[index];
                final isSelected = controller.selectedStarterAsset == starter;

                return GestureDetector(
                  onTap: () {
                    TuxImageCache.load(starter);
                    controller.setStarter(starter);
                  },
                  child: Container(
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFDBEAFE) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? const <BoxShadow>[
                              BoxShadow(color: Color(0x332563EB), blurRadius: 6, offset: Offset(0, 2))
                            ]
                          : null,
                    ),
                    child: Image.asset(starter, fit: BoxFit.contain),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StampsShelf extends StatelessWidget {
  const StampsShelf({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    final currentCat = controller.selectedStampCategory;
    final stamps = TuxAssets.stampsByCategory[currentCat] ?? <TuxStamp>[];

    return Container(
      height: 64,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
      ),
      child: Row(
        children: <Widget>[
          // Category Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TuxAssets.stampCategories.entries.map((entry) {
                final isSelected = entry.key == currentCat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => controller.setStampCategory(entry.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFD97706) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFD97706) : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: Text(
                        I18n.instance.stampCategory(entry.key),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const VerticalDivider(width: 16, color: Color(0xFFCBD5E1)),

          // Horizontal scroll of authentic Tux Paint stamp images
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stamps.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final stamp = stamps[index];
                final isSelected = controller.selectedStampAsset == stamp.assetPath;

                return GestureDetector(
                  onTap: () {
                    TuxImageCache.load(stamp.assetPath);
                    controller.setStamp(stamp.assetPath);
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFDE68A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? const <BoxShadow>[
                              BoxShadow(color: Color(0x33D97706), blurRadius: 6, offset: Offset(0, 2))
                            ]
                          : null,
                    ),
                    child: Image.asset(
                      stamp.assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),

          const VerticalDivider(width: 14, color: Color(0xFFCBD5E1)),

          // Intuitive Stamp Size Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  I18n.instance.stampSize,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                ),
                const SizedBox(width: 6),
                _StampSizeStep(
                  level: 1,
                  label: 'S',
                  diameter: 16,
                  isSelected: controller.stampSizeLevel == 1,
                  onTap: () => controller.setStampSizeLevel(1),
                ),
                const SizedBox(width: 4),
                _StampSizeStep(
                  level: 2,
                  label: 'M',
                  diameter: 22,
                  isSelected: controller.stampSizeLevel == 2,
                  onTap: () => controller.setStampSizeLevel(2),
                ),
                const SizedBox(width: 4),
                _StampSizeStep(
                  level: 3,
                  label: 'L',
                  diameter: 28,
                  isSelected: controller.stampSizeLevel == 3,
                  onTap: () => controller.setStampSizeLevel(3),
                ),
                const SizedBox(width: 4),
                _StampSizeStep(
                  level: 4,
                  label: 'XL',
                  diameter: 36,
                  isSelected: controller.stampSizeLevel == 4,
                  onTap: () => controller.setStampSizeLevel(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BrushesShelf extends StatelessWidget {
  const BrushesShelf({
    super.key,
    required this.controller,
    this.title = 'Kształt pędzla:',
  });

  final DrawingController controller;
  final String title;

  @override
  Widget build(BuildContext context) {
    const brushes = TuxAssets.brushes;

    return Container(
      height: 56,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 2),
      ),
      child: Row(
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
          const SizedBox(width: 10),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: brushes.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final brush = brushes[index];
                final isSelected = controller.selectedBrushAsset == brush.assetPath;

                return GestureDetector(
                  onTap: () {
                    TuxImageCache.load(brush.assetPath);
                    controller.setBrush(brush.assetPath);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFBBF7D0) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                    ),
                    child: Center(
                      child: ClipRect(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          widthFactor: 1.0 / brush.frames,
                          child: Image.asset(
                            brush.assetPath,
                            fit: BoxFit.contain,
                            color: controller.currentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShapesShelf extends StatelessWidget {
  const ShapesShelf({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A), width: 2),
      ),
      child: Row(
        children: <Widget>[
          _ShapeOptionButton(
            label: I18n.instance.shapeCircle,
            isSelected: controller.selectedShape == ShapeType.circle,
            onTap: () => controller.setShape(ShapeType.circle),
          ),
          const SizedBox(width: 8),
          _ShapeOptionButton(
            label: I18n.instance.shapeSquare,
            isSelected: controller.selectedShape == ShapeType.rectangle,
            onTap: () => controller.setShape(ShapeType.rectangle),
          ),
          const SizedBox(width: 8),
          _ShapeOptionButton(
            label: I18n.instance.shapeTriangle,
            isSelected: controller.selectedShape == ShapeType.triangle,
            onTap: () => controller.setShape(ShapeType.triangle),
          ),
          const SizedBox(width: 8),
          _ShapeOptionButton(
            label: I18n.instance.shapeStar,
            isSelected: controller.selectedShape == ShapeType.star,
            onTap: () => controller.setShape(ShapeType.star),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => controller.setShape(controller.selectedShape, filled: !controller.shapeFilled),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: controller.shapeFilled ? const Color(0xFFD97706) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD97706), width: 2),
              ),
              child: Text(
                controller.shapeFilled ? I18n.instance.shapeFilled : I18n.instance.shapeOutline,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: controller.shapeFilled ? Colors.white : const Color(0xFFD97706),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShapeOptionButton extends StatelessWidget {
  const _ShapeOptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDE68A) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isSelected ? const Color(0xFF92400E) : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _StampSizeStep extends StatelessWidget {
  const _StampSizeStep({
    required this.level,
    required this.label,
    required this.diameter,
    required this.isSelected,
    required this.onTap,
  });

  final int level;
  final String label;
  final double diameter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFEF3C7) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.5 : 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD97706) : const Color(0xFF94A3B8),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
