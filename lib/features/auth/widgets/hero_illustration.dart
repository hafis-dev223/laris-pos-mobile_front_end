import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// Ilustrasi meja kasir kedai kopi + badge "Usaha lancar".
/// Diganti dengan foto asli lewat Image.asset kalau sudah ada.
class HeroIllustration extends StatelessWidget {
  const HeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 2.1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _CafePainter()),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(color: Color(0x1F000000), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 13, color: AppColors.brand),
                    SizedBox(width: 6),
                    Text(
                      'Usaha lancar, hari lebih ringan.',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.fg),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CafePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gambar dalam kanvas 420 x 200, lalu diskalakan ke ukuran widget.
    canvas.scale(size.width / 420, size.height / 200);

    void box(double x, double y, double w, double h, double r, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
        Paint()..color = c,
      );
    }

    // Dinding & meja
    box(0, 0, 420, 200, 0, const Color(0xFFEBDCC6));
    box(0, 0, 420, 120, 0, const Color(0xFFF1E5D1));
    box(0, 128, 420, 72, 0, const Color(0xFFB98B5E));
    box(0, 124, 420, 8, 0, const Color(0xFFD2A878));

    // Rak
    const shelf = Color(0xFFA97A4C);
    box(30, 38, 170, 5, 2, shelf);
    box(30, 76, 170, 5, 2, shelf);
    box(236, 30, 150, 5, 2, shelf);

    // Tanaman
    final leafDark = Paint()..color = const Color(0xFF4E8A5E);
    final leafLight = Paint()..color = const Color(0xFF5FA070);
    canvas.drawPath(
      Path()
        ..moveTo(52, 38)
        ..cubicTo(44, 24, 48, 14, 54, 8)
        ..cubicTo(62, 16, 62, 28, 52, 38),
      leafDark,
    );
    canvas.drawPath(
      Path()
        ..moveTo(56, 38)
        ..cubicTo(62, 28, 70, 26, 78, 28)
        ..cubicTo(76, 38, 68, 42, 56, 38),
      leafLight,
    );
    box(46, 32, 16, 6, 2, const Color(0xFFF4F0E8));

    // Cangkir & stoples di rak
    const cream = Color(0xFFF7F3EC);
    box(96, 26, 14, 12, 3, cream);
    box(116, 26, 14, 12, 3, cream);
    box(136, 28, 12, 10, 3, AppColors.brand);
    box(70, 58, 22, 18, 4, const Color(0xFFD9C2A0));
    box(98, 52, 18, 24, 4, const Color(0xFF7A5A3A));
    box(124, 56, 20, 20, 4, const Color(0xFFE8D6B8));

    // Bingkai & lampu
    final frame = Paint()
      ..color = const Color(0xFFC9A97C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    box(252, 46, 30, 40, 3, const Color(0xFFF8F1E4));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(252, 46, 30, 40), const Radius.circular(3)), frame);
    box(292, 52, 26, 30, 3, const Color(0xFFF8F1E4));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(292, 52, 26, 30), const Radius.circular(3)), frame);
    canvas.drawLine(
      const Offset(334, 0),
      const Offset(334, 34),
      Paint()
        ..color = const Color(0xFF6E5238)
        ..strokeWidth = 2,
    );
    canvas.drawPath(
      Path()
        ..moveTo(322, 54)
        ..arcToPoint(const Offset(346, 54), radius: const Radius.elliptical(12, 18))
        ..close(),
      Paint()..color = const Color(0xFFE9B94F),
    );

    // Mesin espresso
    box(236, 76, 96, 62, 8, const Color(0xFFBFC8C6));
    box(236, 76, 96, 14, 6, const Color(0xFF98A5A2));
    box(248, 98, 72, 8, 3, const Color(0xFF8C9996));
    box(256, 106, 8, 18, 3, const Color(0xFF2E3836));
    box(292, 106, 8, 18, 3, const Color(0xFF2E3836));
    canvas.drawCircle(const Offset(344, 104), 14, Paint()..color = const Color(0xFFD9DFDD));
    canvas.drawCircle(const Offset(344, 104), 9, Paint()..color = const Color(0xFFEEF2F1));
    canvas.drawLine(
      const Offset(344, 104),
      const Offset(349, 99),
      Paint()
        ..color = const Color(0xFF4A5654)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Piring & croissant
    canvas.drawOval(const Rect.fromLTWH(62, 140, 92, 20), Paint()..color = const Color(0xFFF8F3EA));
    canvas.drawPath(
      Path()
        ..moveTo(80, 148)
        ..cubicTo(84, 134, 100, 128, 114, 132)
        ..cubicTo(126, 135, 134, 142, 138, 150)
        ..cubicTo(128, 156, 98, 158, 80, 148),
      Paint()..color = const Color(0xFFD8963F),
    );

    // Gelas & cangkir di meja
    box(372, 116, 32, 30, 5, cream);
    box(378, 108, 20, 10, 3, AppColors.brand);
    box(190, 136, 28, 22, 4, cream);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}