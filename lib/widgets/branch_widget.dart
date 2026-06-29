import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class BranchWidget extends StatelessWidget {
  final BranchModel branch;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(BranchModel) onUpdate;

  const BranchWidget({
    super.key,
    required this.branch,
    required this.isSelected,
    required this.onSelect,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final pad = branch.length + 80.0;

    return Positioned(
      left: branch.x - pad,
      top: branch.y - pad,
      child: GestureDetector(
        onTap: branch.isLocked ? null : onSelect,
        onPanUpdate: branch.isLocked
            ? null
            : (d) => onUpdate(branch.copyWith(
                  x: branch.x + d.delta.dx,
                  y: branch.y + d.delta.dy,
                )),
        child: Transform(
          transform: Matrix4.identity()
            ..rotateZ(branch.rotation)
            ..scale(branch.scaleX, 1.0),
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size(pad * 2, pad * 2),
            painter: BranchPainter(branch: branch, isSelected: isSelected),
          ),
        ),
      ),
    );
  }
}

class BranchPainter extends CustomPainter {
  final BranchModel branch;
  final bool isSelected;

  BranchPainter({required this.branch, required this.isSelected});

  // نقطة البداية والنهاية
  Offset get _center => Offset(branch.length + 80, branch.length + 80);

  Offset _endPoint() {
    final c = _center;
    return Offset(
      c.dx + branch.length * math.cos(branch.angle),
      c.dy - branch.length * math.sin(branch.angle),
    );
  }

  Offset _ctrlPoint() {
    final c = _center;
    return Offset(
      c.dx + branch.length * 0.5 * math.cos(branch.angle + branch.curve),
      c.dy - branch.length * 0.5 * math.sin(branch.angle + branch.curve),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = _center;
    final end = _endPoint();
    final ctrl = _ctrlPoint();
    final baseColor = Color(branch.color);
    final darkColor = _darken(baseColor, 0.22);
    final lightColor = _lighten(baseColor, 0.18);

    // ── مسار الغصن ──
    Path branchPath;
    switch (branch.style) {
      case BranchStyle.straight:
        branchPath = Path()..moveTo(c.dx, c.dy)..lineTo(end.dx, end.dy);
        break;
      case BranchStyle.zigzag:
        branchPath = _zigzagPath(c, end);
        break;
      case BranchStyle.vine:
        branchPath = _vinePath(c, end, ctrl);
        break;
      case BranchStyle.drooping:
        branchPath = _droopingPath(c, end);
        break;
      default:
        branchPath = Path()..moveTo(c.dx, c.dy)..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    }

    // ── هالة التحديد ──
    if (isSelected) {
      canvas.drawPath(
        branchPath,
        Paint()
          ..color = const Color(0xFFFFD54F).withOpacity(0.4)
          ..strokeWidth = branch.thickness + 10
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // ── الغصن بتدرج لوني ──
    final metrics = branchPath.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final total = metrics.first.length;
      final steps = (total / 4).ceil();
      for (int i = 0; i < steps; i++) {
        final t0 = (i / steps) * total;
        final t1 = ((i + 1) / steps) * total;
        final segment = metrics.first.extractPath(t0, t1);
        final progress = i / steps;
        // يرفع بالسُّمك من الجذر إلى الطرف
        final segThick = branch.thickness * (1.0 - progress * 0.55);
        canvas.drawPath(
          segment,
          Paint()
            ..color = Color.lerp(darkColor, lightColor, progress * 0.5)!
            ..strokeWidth = segThick.clamp(2.0, branch.thickness)
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // ── تفاصيل اللحاء على الغصن ──
    _drawBranchBark(canvas, c, end, ctrl, darkColor);

    // ── الأوراق ──
    for (final leaf in branch.leaves) {
      _drawLeaf(canvas, end, leaf);
    }

    // ── الدائرة التفاعلية في الرأس (فقط عند التحديد) ──
    if (isSelected) {
      canvas.drawCircle(
        end,
        branch.headRadius * 0.55,
        Paint()
          ..color = const Color(0xFFFFD54F).withOpacity(0.9)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        end,
        branch.headRadius * 0.55,
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
      // أيقونة إضافة
      final tp = TextPainter(
        text: const TextSpan(text: '+', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, end - Offset(tp.width / 2, tp.height / 2));
    }

    // ── اسم الغصن ──
    _drawName(canvas, end);

    // ── قفل ──
    if (branch.isLocked) {
      final lp = TextPainter(
        text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 13)),
        textDirection: TextDirection.ltr,
      )..layout();
      lp.paint(canvas, c - Offset(lp.width / 2, lp.height + 8));
    }
  }

  // ═══ مسارات الأشكال ═══

  Path _zigzagPath(Offset start, Offset end) {
    final path = Path()..moveTo(start.dx, start.dy);
    final steps = 5;
    final dx = (end.dx - start.dx) / steps;
    final dy = (end.dy - start.dy) / steps;
    final perp = Offset(-dy, dx) * 0.25;
    for (int i = 1; i <= steps; i++) {
      final t = i / steps;
      final mid = Offset(
        start.dx + dx * i + (i.isEven ? perp.dx : -perp.dx),
        start.dy + dy * i + (i.isEven ? perp.dy : -perp.dy),
      );
      path.lineTo(mid.dx, mid.dy);
    }
    return path;
  }

  Path _vinePath(Offset start, Offset end, Offset ctrl) {
    final path = Path()..moveTo(start.dx, start.dy);
    for (double t = 0; t <= 1.0; t += 0.1) {
      final x = _bezier(start.dx, ctrl.dx, end.dx, t);
      final y = _bezier(start.dy, ctrl.dy, end.dy, t) +
          math.sin(t * math.pi * 3) * 6;
      path.lineTo(x, y);
    }
    return path;
  }

  Path _droopingPath(Offset start, Offset end) {
    final mid = Offset(
      (start.dx + end.dx) / 2,
      math.max(start.dy, end.dy) + branch.length * 0.28,
    );
    return Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
  }

  double _bezier(double a, double b, double c, double t) =>
      (1 - t) * (1 - t) * a + 2 * (1 - t) * t * b + t * t * c;

  // ═══ لحاء الغصن ═══
  void _drawBranchBark(Canvas canvas, Offset start, Offset end, Offset ctrl, Color dark) {
    final rng = math.Random(branch.id.hashCode);
    final paint = Paint()
      ..color = dark.withOpacity(0.2)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final t = 0.2 + rng.nextDouble() * 0.6;
      final px = _bezier(start.dx, ctrl.dx, end.dx, t);
      final py = _bezier(start.dy, ctrl.dy, end.dy, t);
      final len = 4.0 + rng.nextDouble() * 6;
      final ang = branch.angle + (rng.nextDouble() - 0.5) * 1.5;
      canvas.drawLine(
        Offset(px, py),
        Offset(px + math.cos(ang + math.pi / 2) * len,
               py - math.sin(ang + math.pi / 2) * len),
        paint,
      );
    }
  }

  // ═══ رسم الأوراق ═══
  void _drawLeaf(Canvas canvas, Offset branchEnd, LeafModel leaf) {
    canvas.save();
    canvas.translate(branchEnd.dx + leaf.x, branchEnd.dy + leaf.y);
    canvas.rotate(leaf.rotation);
    canvas.scale(leaf.scaleX, 1.0);

    final w = leaf.width;
    final h = leaf.height;
    final baseColor = Color(leaf.color);
    final darkLeaf = _darken(baseColor, 0.28);
    final lightLeaf = _lighten(baseColor, 0.22);

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [lightLeaf, baseColor, darkLeaf],
    ).createShader(Rect.fromCenter(center: Offset.zero, width: w, height: h));

    final paint = Paint()..shader = gradient..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = darkLeaf.withOpacity(0.5)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    Path leafPath;
    switch (leaf.style) {
      case LeafStyle.pointed:
        leafPath = _pointedLeaf(w, h);
        break;
      case LeafStyle.round:
        leafPath = _roundLeaf(w, h);
        break;
      case LeafStyle.heart:
        leafPath = _heartLeaf(w, h);
        break;
      case LeafStyle.pine:
        _drawPineLeaf(canvas, w, h, baseColor, darkLeaf);
        canvas.restore();
        return;
      case LeafStyle.maple:
        leafPath = _mapleLeaf(w, h);
        break;
      case LeafStyle.palm:
        leafPath = _palmLeaf(w, h);
        break;
      case LeafStyle.feather:
        leafPath = _featherLeaf(w, h);
        break;
      default:
        leafPath = _ovalLeaf(w, h);
    }

    // ظل خفيف
    canvas.drawPath(
      leafPath,
      Paint()
        ..color = Colors.black.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(leafPath, paint);
    canvas.drawPath(leafPath, strokePaint);

    // العرق الأوسط
    _drawVein(canvas, leafPath, w, h, darkLeaf, leaf.style);

    // الاسم
    if (leaf.name.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: leaf.name,
          style: TextStyle(
            fontFamily: 'Amiri', fontSize: 8,
            color: Colors.white.withOpacity(0.9),
            shadows: [Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 2)],
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: w * 0.9);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2 + h * 0.1));
    }

    canvas.restore();
  }

  // ═══ أشكال الأوراق ═══

  Path _ovalLeaf(double w, double h) => Path()
    ..moveTo(0, -h / 2)
    ..cubicTo(w * 0.55, -h / 2, w * 0.55, h / 2, 0, h / 2)
    ..cubicTo(-w * 0.55, h / 2, -w * 0.55, -h / 2, 0, -h / 2);

  Path _pointedLeaf(double w, double h) => Path()
    ..moveTo(0, -h / 2)
    ..cubicTo(w * 0.6, -h * 0.15, w * 0.5, h * 0.3, 0, h / 2)
    ..cubicTo(-w * 0.5, h * 0.3, -w * 0.6, -h * 0.15, 0, -h / 2);

  Path _roundLeaf(double w, double h) {
    final r = math.min(w, h) * 0.5;
    return Path()..addOval(Rect.fromCenter(center: Offset.zero, width: w, height: h * 0.85));
  }

  Path _heartLeaf(double w, double h) {
    final path = Path();
    final s = w * 0.5;
    path.moveTo(0, h * 0.35);
    path.cubicTo(-s * 0.1, h * 0.1, -s, -h * 0.05, -s * 0.9, -h * 0.3);
    path.cubicTo(-s * 0.8, -h * 0.55, -s * 0.1, -h * 0.5, 0, -h * 0.2);
    path.cubicTo(s * 0.1, -h * 0.5, s * 0.8, -h * 0.55, s * 0.9, -h * 0.3);
    path.cubicTo(s, -h * 0.05, s * 0.1, h * 0.1, 0, h * 0.35);
    return path;
  }

  Path _mapleLeaf(double w, double h) {
    // ورقة القيقب بفروع 5
    final path = Path();
    final r = w * 0.5;
    final ir = r * 0.38;
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      final nextAngle = angle + math.pi / 5;
      if (i == 0) path.moveTo(r * math.cos(angle), r * math.sin(angle));
      else path.lineTo(r * math.cos(angle), r * math.sin(angle));
      path.lineTo(ir * math.cos(nextAngle), ir * math.sin(nextAngle));
    }
    path.close();
    return path;
  }

  Path _palmLeaf(double w, double h) {
    // ورقة النخيل: شكل ريشي طويل
    final path = Path()
      ..moveTo(0, -h / 2)
      ..cubicTo(w * 0.7, -h * 0.3, w * 0.8, h * 0.1, w * 0.2, h / 2)
      ..cubicTo(0, h * 0.3, 0, h * 0.1, 0, 0)
      ..cubicTo(0, h * 0.1, 0, h * 0.3, -w * 0.2, h / 2)
      ..cubicTo(-w * 0.8, h * 0.1, -w * 0.7, -h * 0.3, 0, -h / 2);
    return path;
  }

  Path _featherLeaf(double w, double h) {
    // ريشة (صنوبر/تنوب)
    final path = Path()
      ..moveTo(0, -h / 2)
      ..cubicTo(w * 0.4, -h * 0.2, w * 0.3, h * 0.2, 0, h / 2)
      ..cubicTo(-w * 0.3, h * 0.2, -w * 0.4, -h * 0.2, 0, -h / 2);
    return path;
  }

  void _drawPineLeaf(Canvas canvas, double w, double h, Color base, Color dark) {
    // إبرة الصنوبر: خط رفيع مدبب
    final paint = Paint()
      ..color = base
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -h / 2), Offset(0, h / 2), paint);
    // فروع جانبية صغيرة
    for (int i = 1; i < 4; i++) {
      final y = -h / 2 + i * h / 4.0;
      final len = w * 0.4 * (1 - i * 0.1);
      canvas.drawLine(Offset(0, y), Offset(len, y + len * 0.3),
          paint..strokeWidth = 1.0..color = dark.withOpacity(0.7));
      canvas.drawLine(Offset(0, y), Offset(-len, y + len * 0.3),
          paint..strokeWidth = 1.0..color = dark.withOpacity(0.7));
    }
  }

  // ═══ عروق الورقة ═══
  void _drawVein(Canvas canvas, Path leafPath, double w, double h, Color dark, LeafStyle style) {
    final veinPaint = Paint()
      ..color = dark.withOpacity(0.35)
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (style == LeafStyle.maple) return;
    if (style == LeafStyle.pine || style == LeafStyle.feather) return;

    // العرق المركزي
    canvas.drawLine(Offset(0, -h * 0.42), Offset(0, h * 0.42), veinPaint);

    // عروق جانبية
    final count = style == LeafStyle.palm ? 4 : 3;
    for (int i = 1; i <= count; i++) {
      final t = i / (count + 1);
      final y = -h * 0.38 + h * 0.76 * t;
      final xLen = w * 0.28 * math.sin(t * math.pi);
      canvas.drawLine(
        Offset(0, y),
        Offset(xLen, y - h * 0.06),
        veinPaint..strokeWidth = 0.5,
      );
      canvas.drawLine(
        Offset(0, y),
        Offset(-xLen, y - h * 0.06),
        veinPaint..strokeWidth = 0.5,
      );
    }
  }

  void _drawName(Canvas canvas, Offset end) {
    if (branch.name.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(
        text: branch.name,
        style: const TextStyle(
          fontFamily: 'Amiri', fontSize: 11,
          color: Color(0xFF3E2723),
          shadows: [Shadow(color: Colors.white, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, end + Offset(-tp.width / 2, 8));
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
  bool shouldRepaint(covariant BranchPainter old) =>
      old.branch != branch || old.isSelected != isSelected;
}
