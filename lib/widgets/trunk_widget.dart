import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class TrunkWidget extends StatelessWidget {
  final TrunkModel trunk;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(TrunkModel) onUpdate;

  const TrunkWidget({
    super.key,
    required this.trunk,
    required this.isSelected,
    required this.onSelect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final w = trunk.thickness * 4;
    final h = trunk.height + trunk.thickness * 2;

    return Positioned(
      left: trunk.x - w / 2,
      top: trunk.y - trunk.height,
      child: GestureDetector(
        onTap: trunk.isLocked ? null : onSelect,
        onPanUpdate: trunk.isLocked
            ? null
            : (d) => onUpdate(trunk.copyWith(
                  x: trunk.x + d.delta.dx,
                  y: trunk.y + d.delta.dy,
                )),
        child: Transform(
          transform: Matrix4.identity()
            ..rotateZ(trunk.rotation)
            ..scale(trunk.scaleX, 1.0),
          alignment: Alignment.bottomCenter,
          child: CustomPaint(
            size: Size(w, h),
            painter: TrunkPainter(trunk: trunk, isSelected: isSelected),
          ),
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
    final bottom = size.height;
    final top = 0.0;
    final hw = trunk.thickness / 2;
    final bend = trunk.bend * size.width * 0.3;

    // ── تحديد الألوان حسب النوع ──
    final baseColor = Color(trunk.color);
    final darkColor = _darken(baseColor, 0.25);
    final lightColor = _lighten(baseColor, 0.2);
    final midColor = _darken(baseColor, 0.1);

    // ── تحديد شكل الجذع ──
    Path trunkPath;
    switch (trunk.style) {
      case TrunkStyle.baobab:
        trunkPath = _baobabPath(cx, bottom, top, hw, bend, size);
        break;
      case TrunkStyle.palm:
        trunkPath = _palmPath(cx, bottom, top, hw, bend);
        break;
      case TrunkStyle.cedar:
        trunkPath = _cedarPath(cx, bottom, top, hw, bend);
        break;
      case TrunkStyle.willow:
        trunkPath = _willowPath(cx, bottom, top, hw, bend);
        break;
      case TrunkStyle.pine:
        trunkPath = _pinePath(cx, bottom, top, hw, bend);
        break;
      default:
        trunkPath = _classicPath(cx, bottom, top, hw, bend);
    }

    // ── هالة التحديد ──
    if (isSelected) {
      canvas.drawPath(
        trunkPath,
        Paint()
          ..color = const Color(0xFFFFD54F).withOpacity(0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
          ..style = PaintingStyle.fill,
      );
    }

    // ── ظل تحت الجذع ──
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + bend * 0.5, bottom - 4),
        width: trunk.thickness * 2.2,
        height: trunk.thickness * 0.35,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // ── رسم الجسم الأساسي ──
    final bodyGrad = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [darkColor, lightColor, midColor, darkColor],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ).createShader(Rect.fromLTWH(cx - trunk.thickness, top, trunk.thickness * 2, bottom - top));

    canvas.drawPath(trunkPath, Paint()..shader = bodyGrad..style = PaintingStyle.fill);

    // ── تفاصيل اللحاء ──
    _drawBark(canvas, cx, bottom, top, hw, bend, darkColor, trunk.style);

    // ── حواف الجذع ──
    canvas.drawPath(
      trunkPath,
      Paint()
        ..color = darkColor.withOpacity(0.6)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );

    // ── الجذور ──
    if (trunk.style != TrunkStyle.palm) {
      _drawRoots(canvas, cx, bottom, hw, darkColor);
    }

    // ── الأسماء ──
    _drawNames(canvas, size, cx, bottom, top, hw);
  }

  // ═══ مسارات الأشكال ═══

  Path _classicPath(double cx, double bottom, double top, double hw, double bend) {
    final bw = hw * 1.5;
    final tw = hw * 0.65;
    return Path()
      ..moveTo(cx - bw, bottom)
      ..cubicTo(cx - bw + bend * 0.3, bottom * 0.7,
                cx - tw * 0.8 + bend * 0.7, bottom * 0.3,
                cx - tw + bend, top + 10)
      ..lineTo(cx + tw + bend, top + 10)
      ..cubicTo(cx + tw * 0.8 + bend * 0.7, bottom * 0.3,
                cx + bw + bend * 0.3, bottom * 0.7,
                cx + bw, bottom)
      ..close();
  }

  Path _baobabPath(double cx, double bottom, double top, double hw, double bend, Size size) {
    final bw = hw * 1.3;
    final belly = hw * 2.2;
    final tw = hw * 0.55;
    return Path()
      ..moveTo(cx - bw, bottom)
      ..cubicTo(cx - belly + bend * 0.2, bottom * 0.75,
                cx - belly + bend * 0.5, bottom * 0.5,
                cx - tw + bend * 0.8, bottom * 0.25)
      ..cubicTo(cx - tw * 0.8 + bend, bottom * 0.15,
                cx - tw + bend, top + 20,
                cx - tw + bend, top + 10)
      ..lineTo(cx + tw + bend, top + 10)
      ..cubicTo(cx + tw + bend, top + 20,
                cx + tw * 0.8 + bend, bottom * 0.15,
                cx + tw + bend * 0.8, bottom * 0.25)
      ..cubicTo(cx + belly + bend * 0.5, bottom * 0.5,
                cx + belly + bend * 0.2, bottom * 0.75,
                cx + bw, bottom)
      ..close();
  }

  Path _palmPath(double cx, double bottom, double top, double hw, double bend) {
    final bw = hw * 1.1;
    final tw = hw * 0.55;
    // جذع النخيل منحني قليلاً
    return Path()
      ..moveTo(cx - bw, bottom)
      ..cubicTo(cx - bw * 0.8 + bend * 0.1, bottom * 0.8,
                cx - tw + bend * 0.6, bottom * 0.4,
                cx - tw + bend, top + 10)
      ..lineTo(cx + tw + bend, top + 10)
      ..cubicTo(cx + tw + bend * 0.6, bottom * 0.4,
                cx + bw * 0.8 + bend * 0.1, bottom * 0.8,
                cx + bw, bottom)
      ..close();
  }

  Path _cedarPath(double cx, double bottom, double top, double hw, double bend) {
    final bw = hw * 1.2;
    final tw = hw * 0.5;
    return Path()
      ..moveTo(cx - bw, bottom)
      ..lineTo(cx - bw * 0.9 + bend * 0.2, bottom * 0.7)
      ..lineTo(cx - tw * 1.1 + bend * 0.6, bottom * 0.35)
      ..lineTo(cx - tw + bend, top + 10)
      ..lineTo(cx + tw + bend, top + 10)
      ..lineTo(cx + tw * 1.1 + bend * 0.6, bottom * 0.35)
      ..lineTo(cx + bw * 0.9 + bend * 0.2, bottom * 0.7)
      ..lineTo(cx + bw, bottom)
      ..close();
  }

  Path _willowPath(double cx, double bottom, double top, double hw, double bend) {
    final bw = hw * 1.1;
    final tw = hw * 0.45;
    // جذع الصفصاف نحيل ومتموج
    return Path()
      ..moveTo(cx - bw, bottom)
      ..cubicTo(cx - bw + bend * 0.2, bottom * 0.65,
                cx + bend * 0.8, bottom * 0.35,
                cx - tw + bend, top + 10)
      ..lineTo(cx + tw + bend, top + 10)
      ..cubicTo(cx + bend * 0.8 + tw * 2, bottom * 0.35,
                cx + bw + bend * 0.2, bottom * 0.65,
                cx + bw, bottom)
      ..close();
  }

  Path _pinePath(double cx, double bottom, double top, double hw, double bend) {
    final bw = hw * 1.0;
    final tw = hw * 0.42;
    return Path()
      ..moveTo(cx - bw, bottom)
      ..cubicTo(cx - bw * 0.85 + bend * 0.25, bottom * 0.68,
                cx - tw * 0.9 + bend * 0.65, bottom * 0.32,
                cx - tw + bend, top + 10)
      ..lineTo(cx + tw + bend, top + 10)
      ..cubicTo(cx + tw * 0.9 + bend * 0.65, bottom * 0.32,
                cx + bw * 0.85 + bend * 0.25, bottom * 0.68,
                cx + bw, bottom)
      ..close();
  }

  // ═══ تفاصيل اللحاء ═══
  void _drawBark(Canvas canvas, double cx, double bottom, double top,
      double hw, double bend, Color dark, TrunkStyle style) {
    final paint = Paint()
      ..color = dark.withOpacity(0.25)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final rng = math.Random(42);

    if (style == TrunkStyle.palm) {
      // حلقات النخيل الأفقية
      final count = (bottom - top) ~/ 18;
      for (int i = 1; i < count; i++) {
        final y = bottom - i * 18.0;
        final progress = i / count;
        final w = hw * (1.1 - progress * 0.4) * 0.7;
        final bx = cx + bend * progress;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(bx, y), width: w * 2, height: w * 0.4),
          0, math.pi, false,
          paint..color = dark.withOpacity(0.18),
        );
      }
    } else if (style == TrunkStyle.baobab) {
      // تشققات عمودية للبوباب
      for (int i = 0; i < 5; i++) {
        final progress = i / 5.0;
        final xOff = cx - hw * 0.8 + i * hw * 0.4;
        final startY = bottom * 0.85 + rng.nextDouble() * 20;
        final endY = top + 30 + rng.nextDouble() * (bottom * 0.4);
        canvas.drawLine(
          Offset(xOff + bend * 0.3, startY),
          Offset(xOff + bend * 0.7 + (rng.nextDouble() - 0.5) * 8, endY),
          paint..strokeWidth = 0.6 + rng.nextDouble(),
        );
      }
    } else {
      // خطوط لحاء عشوائية للأشجار الأخرى
      for (int i = 0; i < 8; i++) {
        final progress = rng.nextDouble();
        final y1 = top + progress * (bottom - top) * 0.8;
        final y2 = y1 + 15 + rng.nextDouble() * 30;
        final xOff = (rng.nextDouble() - 0.5) * hw * 0.9;
        canvas.drawLine(
          Offset(cx + xOff + bend * progress, y1),
          Offset(cx + xOff * 1.1 + bend * (progress + 0.1) + (rng.nextDouble() - 0.5) * 4, y2.clamp(0, bottom)),
          paint..strokeWidth = 0.5 + rng.nextDouble() * 0.8,
        );
      }
    }
  }

  // ═══ الجذور ═══
  void _drawRoots(Canvas canvas, double cx, double bottom, double hw, Color dark) {
    final paint = Paint()
      ..color = dark.withOpacity(0.55)
      ..strokeWidth = hw * 0.28
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roots = [
      (-hw * 1.1, hw * 0.9, -hw * 2.2, hw * 0.3),
      (-hw * 0.6, hw * 0.5, -hw * 1.4, -hw * 0.2),
      (hw * 0.6, hw * 0.5, hw * 1.4, -hw * 0.2),
      (hw * 1.1, hw * 0.9, hw * 2.2, hw * 0.3),
    ];
    for (final (sx, sy, ex, ey) in roots) {
      final path = Path()
        ..moveTo(cx + sx * 0.3, bottom - 4)
        ..quadraticBezierTo(cx + sx * 0.7, bottom + sy * 0.5, cx + ex, bottom + ey);
      canvas.drawPath(path, paint..strokeWidth = hw * 0.22);
    }
  }

  // ═══ الأسماء ═══
  void _drawNames(Canvas canvas, Size size, double cx, double bottom, double top, double hw) {
    if (trunk.names.isEmpty) return;
    final usable = (bottom - top) * 0.7;
    final step = trunk.names.length > 1 ? usable / (trunk.names.length) : 0.0;
    for (int i = 0; i < trunk.names.length && i < 12; i++) {
      final y = bottom - usable * 0.15 - i * step;
      final tp = TextPainter(
        text: TextSpan(
          text: trunk.names[i],
          style: TextStyle(
            fontFamily: 'Amiri', fontSize: 9.5,
            color: Colors.white.withOpacity(0.85),
            shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: hw * 1.6);
      tp.paint(canvas, Offset(cx - tp.width / 2, y - tp.height / 2));
    }
  }

  Color _darken(Color c, double amount) => Color.fromARGB(
    c.alpha,
    (c.red * (1 - amount)).round().clamp(0, 255),
    (c.green * (1 - amount)).round().clamp(0, 255),
    (c.blue * (1 - amount)).round().clamp(0, 255),
  );

  Color _lighten(Color c, double amount) => Color.fromARGB(
    c.alpha,
    (c.red + (255 - c.red) * amount).round().clamp(0, 255),
    (c.green + (255 - c.green) * amount).round().clamp(0, 255),
    (c.blue + (255 - c.blue) * amount).round().clamp(0, 255),
  );

  @override
  bool shouldRepaint(covariant TrunkPainter old) =>
      old.trunk != trunk || old.isSelected != isSelected;
}
