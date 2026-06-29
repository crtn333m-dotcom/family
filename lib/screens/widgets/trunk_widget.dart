import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class TrunkWidget extends StatelessWidget {
  final TrunkModel trunk;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(TrunkModel) onUpdate;

  const TrunkWidget({
    super.key, required this.trunk, required this.isSelected,
    required this.onSelect, required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final w = trunk.thickness * 3;
    final h = trunk.height + 40;
    return Positioned(
      left: trunk.x - w / 2,
      top: trunk.y - trunk.height,
      child: GestureDetector(
        onTap: trunk.isLocked ? null : onSelect,
        onPanUpdate: trunk.isLocked ? null : (d) => onUpdate(trunk.copyWith(
          x: trunk.x + d.delta.dx, y: trunk.y + d.delta.dy,
        )),
        child: CustomPaint(
          size: Size(w, h),
          painter: TrunkPainter(trunk: trunk, isSelected: isSelected),
        ),
      ),
    );
  }
}

class TrunkPainter extends CustomPainter {
  final TrunkModel trunk;
  final bool isSelected;
  TrunkPainter({required this.trunk, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final base = size.height - 20;
    final top = 20.0;

    // Glow عند التحديد
    if (isSelected) {
      canvas.drawRect(
        Rect.fromLTWH(cx - trunk.thickness / 2 - 6, top - 6,
            trunk.thickness + 12, base - top + 12),
        Paint()
          ..color = const Color(0xFFD4A55A).withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    final path = _buildTrunkPath(cx, base, top);

    // ظل
    canvas.drawPath(path, Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // الجذع
    canvas.drawPath(path, Paint()
      ..shader = LinearGradient(
        colors: [
          Color(trunk.color).withOpacity(0.7),
          Color(trunk.color),
          Color(trunk.color).withOpacity(0.85),
        ],
        stops: const [0, 0.5, 1],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(
          cx - trunk.thickness / 2, top, trunk.thickness, base - top))
      ..style = PaintingStyle.fill);

    // تفاصيل اللحاء
    _drawBark(canvas, cx, base, top);

    // الأسماء
    _drawNames(canvas, size, cx, base, top);

    // قفل
    if (trunk.isLocked) {
      _drawLock(canvas, cx, top - 16);
    }
  }

  Path _buildTrunkPath(double cx, double base, double top) {
    final hw = trunk.thickness / 2;
    switch (trunk.style) {
      case TrunkStyle.baobab:
        return Path()
          ..moveTo(cx - hw * 1.8, base)
          ..quadraticBezierTo(cx - hw * 2.2, base * 0.6, cx - hw * 0.8, top)
          ..lineTo(cx + hw * 0.8, top)
          ..quadraticBezierTo(cx + hw * 2.2, base * 0.6, cx + hw * 1.8, base)
          ..close();
      case TrunkStyle.palm:
        return Path()
          ..moveTo(cx - hw * 0.7, base)
          ..quadraticBezierTo(cx - hw * 1.2, base * 0.5, cx - hw * 0.5, top)
          ..lineTo(cx + hw * 0.5, top)
          ..quadraticBezierTo(cx + hw * 1.2, base * 0.5, cx + hw * 0.7, base)
          ..close();
      case TrunkStyle.cedar:
        return Path()
          ..moveTo(cx - hw * 1.1, base)
          ..lineTo(cx - hw * 0.6, top)
          ..lineTo(cx + hw * 0.6, top)
          ..lineTo(cx + hw * 1.1, base)
          ..close();
      default: // classic
        return Path()
          ..moveTo(cx - hw * 1.3, base)
          ..quadraticBezierTo(cx - hw * 0.9, base * 0.5, cx - hw * 0.7, top)
          ..lineTo(cx + hw * 0.7, top)
          ..quadraticBezierTo(cx + hw * 0.9, base * 0.5, cx + hw * 1.3, base)
          ..close();
    }
  }

  void _drawBark(Canvas canvas, double cx, double base, double top) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final spacing = (base - top) / 8;
    for (int i = 1; i < 8; i++) {
      final y = top + i * spacing;
      canvas.drawLine(
        Offset(cx - trunk.thickness * 0.35, y),
        Offset(cx + trunk.thickness * 0.35, y),
        paint,
      );
    }
  }

  void _drawNames(Canvas canvas, Size size, double cx, double base, double top) {
    if (trunk.names.isEmpty) return;
    final available = base - top - 16;
    final spacing = math.min(available / trunk.names.length, 22.0);
    for (int i = 0; i < trunk.names.length; i++) {
      final tp = TextPainter(
        text: TextSpan(
          text: trunk.names[i],
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: math.min(11, trunk.thickness * 0.28).clamp(7, 13),
            color: Colors.white.withOpacity(0.88),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: trunk.thickness * 1.8);
      final y = top + 8 + i * spacing;
      tp.paint(canvas, Offset(cx - tp.width / 2, y));
    }
  }

  void _drawLock(Canvas canvas, double cx, double y) {
    final tp = TextPainter(
      text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant TrunkPainter old) =>
      old.trunk != trunk || old.isSelected != isSelected;
}
