// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/legacy.dart';
import '../../controllers/drawing_controller.dart';
import '../../services/i18n.dart';
import '../../services/window_service.dart';

class KidsTopBar extends StatelessWidget {
  const KidsTopBar({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    final isDesktop = !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

    final content = Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 2),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Logo & Name
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/app_icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'KidsPaint',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Tux Edition',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF15803D),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // About & License Info Dialog
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFF64748B)),
            tooltip: 'O programie / About',
            onPressed: () => _showAboutDialog(context),
          ),

          const SizedBox(width: 8),

          // Language Selector Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AppLanguage>(
                value: I18n.instance.current,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF475569)),
                items: AppLanguage.values.map((lang) {
                  return DropdownMenuItem<AppLanguage>(
                    value: lang,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(lang.flag, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          lang.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (lang) {
                  if (lang != null) controller.setLanguage(lang);
                },
              ),
            ),
          ),

          const Spacer(),

          // Desktop Window Controls & Fullscreen Zoom
          if (isDesktop) ...<Widget>[
            // Fullscreen / Zoom Toggle
            _TopBarButton(
              tooltip: 'Pełny ekran / Powiększ',
              icon: Icons.fullscreen_rounded,
              bgColor: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              onTap: () => WindowService.instance.toggleFullScreen(),
            ),
            const SizedBox(width: 8),

            // Maximize / Restore Toggle
            _TopBarButton(
              tooltip: 'Dopasuj do ekranu',
              icon: Icons.crop_square_rounded,
              bgColor: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              onTap: () => WindowService.instance.toggleMaximize(),
            ),
            const SizedBox(width: 8),

            // Minimize
            _TopBarButton(
              tooltip: 'Zminimalizuj',
              icon: Icons.remove_rounded,
              bgColor: const Color(0xFFF1F5F9),
              iconColor: const Color(0xFF64748B),
              onTap: () => windowManager.minimize(),
            ),
            const SizedBox(width: 8),

            // Close
            _TopBarButton(
              tooltip: 'Zamknij KidsPaint',
              icon: Icons.close_rounded,
              bgColor: const Color(0xFFFFE4E6),
              iconColor: const Color(0xFFE11D48),
              onTap: () => windowManager.close(),
            ),
          ],
        ],
      ),
    );

    if (isDesktop) {
      return DragToMoveArea(child: content);
    }
    return content;
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Image.asset('assets/images/app_icon.png', width: 32, height: 32),
              const SizedBox(width: 10),
              const Text('O programie KidsPaint', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'KidsPaint (Tux Edition) to nowoczesna aplikacja malarska dla dzieci, bazująca na kultowym projekcie Tux Paint.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  'Atrybucja i licencja:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  '• Oryginalny projekt Tux Paint: © 2002–2026 Bill Kendrick i społeczność New Breed Software (www.tuxpaint.org).\n'
                  '• Wydane na licencji GNU General Public License v2 (GPL-2.0-or-later).\n'
                  '• Kod źródłowy jest w 100% otwarty (Open Source).\n'
                  '• Wszystkie autentyczne pędzle, stemple i dźwięki zachowują swoje licencje wolnego oprogramowania.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Zamknij', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.tooltip,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 20, color: iconColor),
        ),
      ),
    );
  }
}
