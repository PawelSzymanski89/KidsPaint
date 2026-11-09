import 'package:flutter/material.dart';
import '../../controllers/drawing_controller.dart';
import '../../services/i18n.dart';

class ToolSidebar extends StatelessWidget {
  const ToolSidebar({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 3),
        ),
      ),
      child: SafeArea(
        right: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          children: <Widget>[
            _ToolItem(
              icon: '🖌️',
              label: I18n.instance.toolBrush,
              tool: KidsTool.brush,
              controller: controller,
            ),
            const SizedBox(height: 8),
            _ToolItem(
              icon: '🐾',
              label: I18n.instance.toolStamps,
              tool: KidsTool.stamps,
              controller: controller,
            ),
            const SizedBox(height: 8),
            _ToolItem(
              icon: '🪄',
              label: I18n.instance.toolMagic,
              tool: KidsTool.magic,
              controller: controller,
            ),
            const SizedBox(height: 8),
            _ToolItem(
              icon: '🪣',
              label: I18n.instance.toolFill,
              tool: KidsTool.fill,
              controller: controller,
            ),
            const SizedBox(height: 8),
            _ToolItem(
              icon: '⭐',
              label: I18n.instance.toolShapes,
              tool: KidsTool.shapes,
              controller: controller,
            ),
            const SizedBox(height: 8),
            _ToolItem(
              icon: '📏',
              label: I18n.instance.toolLines,
              tool: KidsTool.lines,
              controller: controller,
            ),
            const SizedBox(height: 8),
            _ToolItem(
              icon: '🐶',
              label: I18n.instance.toolColoring,
              tool: KidsTool.coloring,
              controller: controller,
            ),
            const SizedBox(height: 8),
            _ToolItem(
              icon: '🧽',
              label: I18n.instance.toolEraser,
              tool: KidsTool.eraser,
              controller: controller,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  const _ToolItem({
    required this.icon,
    required this.label,
    required this.tool,
    required this.controller,
  });

  final String icon;
  final String label;
  final KidsTool tool;
  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.currentTool == tool;

    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => controller.setTool(tool),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          height: 86,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFE5E5) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF5A5F) : Colors.transparent,
              width: 3.5,
            ),
            boxShadow: isSelected
                ? const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x44FF5A5F),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                icon,
                style: const TextStyle(fontSize: 26),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? const Color(0xFFFF334B) : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
