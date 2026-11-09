import 'package:flutter/material.dart';
import '../../controllers/drawing_controller.dart';
import '../../services/sound_engine.dart';

class TuxBottomBar extends StatelessWidget {
  const TuxBottomBar({
    super.key,
    required this.controller,
  });

  final DrawingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Interactive Tux mascot that giggles when tapped
          GestureDetector(
            onTap: () => TuxSoundEngine.instance.playTuxGiggle(),
            child: Tooltip(
              message: 'Kliknij Tuxa!',
              child: Image.asset(
                'assets/tuxpaint/stamps/tux/tux-yay2.png',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Speech bubble arrow
          CustomPaint(
            size: const Size(8, 14),
            painter: _SpeechArrowPainter(),
          ),

          // Speech bubble text
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                controller.tuxMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Mute / Unmute audio button
          IconButton(
            icon: Icon(
              TuxSoundEngine.instance.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: TuxSoundEngine.instance.isMuted ? const Color(0xFF94A3B8) : const Color(0xFF2563EB),
              size: 20,
            ),
            tooltip: TuxSoundEngine.instance.isMuted ? 'Włącz dźwięki' : 'Wycisz dźwięki',
            onPressed: () => controller.toggleAudioMute(),
          ),
        ],
      ),
    );
  }
}

class _SpeechArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF8FAFC)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
