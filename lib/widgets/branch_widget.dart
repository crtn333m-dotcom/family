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
    final pad = branch.length + 100.0;

    return Stack(
      children: [
        // ── الغصن نفسه ──
        Positioned(
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
        ),

        // ── الأوراق المستقلة ──
        ...branch.leaves.map((leaf) => _LeafWidget(
              leaf: leaf,
              branch: branch,
              onUpdate: (updatedLeaf) {
                final newLeaves = branch.leaves
                    .map((l) => l.id == updatedLeaf.id ? updatedLeaf : l)
                    .toList();
                onUpdate(branch.copyWith(leaves: newLeaves));
              },
            )),
      ],
    );
  }
}

// ════════════════════════════════════════
//  ويدجت مستقل لكل ورقة — قابل للسحب
// ════════════════════════════════════════
class _LeafWidget extends StatelessWidget {
  final LeafModel leaf;
  final BranchModel branch;
  final Function(LeafModel) onUpdate;

  const _LeafWidget({
    required this.leaf,
    required this.branch,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // الموضع المطلق للورقة على الكانفاس
    final absX = branch.x + leaf.x;
    final absY = branch.y + leaf.y;
    final w = leaf.width + 20;
    final h = leaf.height + 20;

    return Positioned(
      left: absX - w / 2,
      top: absY - h / 2,
      child: GestureDetector(
        onPanUpdate: leaf.isLocked
            ? null
            : (d) => onUpdate(leaf.copyWith(
                  x: leaf.x + d.delta.dx,
                  y: leaf.y + d.delta.dy,
                )),
        child: Transform(
          transform: Matrix4.identity()
            ..rotateZ(leaf.rotation)
            ..scale(leaf.scaleX, 1.0),
          alignment: Alignment.center,
          child: CustomPaint(
            size: Size(w, h),
            painter: _LeafPainter(leaf: leaf),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
//  رسّام الغصن (بدون أوراق — أصبحت مستقلة)
// ════════════════════════════════════════
class BranchPainter extends CustomPainter {
  final BranchModel branch;
  final bool isSelected;

  BranchPainter({required this.branch, required this.isSelected});

  Offset get _center => Offset(branch.length + 100, branch.length + 100);

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
    final darkColor = _darken(baseColor, 0.25);
    final lightColor = _lighten(baseColor, 0.15);

    // ── مسار الغصن ──
    final branchPath = _buildPath(c, end, ctrl);

    // ── هالة التحديد ──
    if (isSelected) {
      canvas.drawPath(
        branchPath,
        Paint()
          ..color = const Color(0xFFFFD54F).withOpacity(0.35)
          ..strokeWidth = branch.thickness + 14
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // ── الغصن بتدرج واقعي تدريجي ──
    _drawRealisticBranch(canvas, branchPath, baseColor, darkColor, lightColor);

    // ── لحاء الغصن ──
    _drawBranchBark(canvas, c, end, ctrl, darkColor);

    // ── نقطة الرأس عند التحديد ──
    if (isSelected) {
      canvas.drawCircle(
        end,
        branch.headRadius * 0.5,
        Paint()
          ..color = const Color(0xFFFFD54F).withOpacity(0.9)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        end,
        branch.headRadius * 0.5,
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );
      final tp = TextPainter(
        text: const TextSpan(
            text: '+',
            style: TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, end - Offset(tp.width / 2, tp.height / 2));
    }

    // ── اسم الغصن ──
    _drawName(canvas, end);

    // ── قفل ──
    if (branch.isLocked) {
      final lp = TextPainter(
        text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      lp.paint(canvas, c - Offset(lp.width / 2, lp.height + 10));
    }
  }

  Path _buildPath(Offset c, Offset end, Offset ctrl) {
    switch (branch.style) {
      case BranchStyle.straight:
        return Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(end.dx, end.dy);
      case BranchStyle.zigzag:
        return _zigzagPath(c, end);
      case BranchStyle.vine:
        return _vinePath(c, end, ctrl);
      case BranchStyle.drooping:
        return _droopingPath(c, end);
      default:
        return Path()
          ..moveTo(c.dx, c.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    }
  }

  void _drawRealisticBranch(Canvas canvas, Path branchPath, Color base,
      Color dark, Color light) {
    final metrics = branchPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final total = metrics.first.length;
    final steps = (total / 3).ceil().clamp(10, 60);

    for (int i = 0; i < steps; i++) {
      final t0 = (i / steps) * total;
      final t1 = ((i + 1) / steps) * total;
      final segment = metrics.first.extractPath(t0, t1);
      final progress = i / steps;

      // سُمك يتناقص من الجذر للطرف
      final segThick =
          (branch.thickness * (1.0 - progress * 0.65)).clamp(1.5, branch.thickness);

      // لون يتدرج: داكن عند الجذر ← فاتح عند الطرف
      final segColor = Color.lerp(dark, light, progress * 0.6)!;

      // ظل جانبي لإضافة عمق
      canvas.drawPath(
        segment,
        Paint()
          ..color = dark.withOpacity(0.25)
          ..strokeWidth = segThick + 2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );

      // الجسم الرئيسي
      canvas.drawPath(
        segment,
        Paint()
          ..color = segColor
          ..strokeWidth = segThick
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );

      // بريق خفيف على الحافة العليا
      canvas.drawPath(
        segment,
        Paint()
          ..color = Colors.white.withOpacity(0.07 * (1 - progress))
          ..strokeWidth = segThick * 0.25
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  Path _zigzagPath(Offset start, Offset end) {
    final path = Path()..moveTo(start.dx, start.dy);
    const steps = 6;
    final dx = (end.dx - start.dx) / steps;
    final dy = (end.dy - start.dy) / steps;
    final perp = Offset(-dy, dx) * 0.22;
    for (int i = 1; i <= steps; i++) {
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
    for (double t = 0; t <= 1.0; t += 0.08) {
      final x = _bezier(start.dx, ctrl.dx, end.dx, t);
      final y = _bezier(start.dy, ctrl.dy, end.dy, t) +
          math.sin(t * math.pi * 4) * 5;
      path.lineTo(x, y);
    }
    return path;
  }

  Path _droopingPath(Offset start, Offset end) {
    final mid = Offset(
      (start.dx + end.dx) / 2,
      math.max(start.dy, end.dy) + branch.length * 0.3,
    );
    return Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
  }

  double _bezier(double a, double b, double c, double t) =>
      (1 - t) * (1 - t) * a + 2 * (1 - t) * t * b + t * t * c;

  void _drawBranchBark(
      Canvas canvas, Offset start, Offset end, Offset ctrl, Color dark) {
    final rng = math.Random(branch.id.hashCode);
    final paint = Paint()
      ..color = dark.withOpacity(0.18)
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final count = (branch.length / 20).round().clamp(3, 8);
    for (int i = 0; i < count; i++) {
      final t = 0.15 + rng.nextDouble() * 0.7;
      final px = _bezier(start.dx, ctrl.dx, end.dx, t);
      final py = _bezier(start.dy, ctrl.dy, end.dy, t);
      final len = 5.0 + rng.nextDouble() * 7;
      final ang = branch.angle + (rng.nextDouble() - 0.5) * 1.8;
      canvas.drawLine(
        Offset(px, py),
        Offset(px + math.cos(ang + math.pi / 2) * len,
            py - math.sin(ang + math.pi / 2) * len),
        paint,
      );
    }
  }

  void _drawName(Canvas canvas, Offset end) {
    if (branch.name.isEmpty) return;
    final tp = TextPainter(
      text: TextSpan(
        text: branch.name,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 11,
          color: Color(0xFF3E2723),
          shadows: [Shadow(color: Colors.white, blurRadius: 3)],
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    tp.paint(canvas, end + Offset(-tp.width / 2, 10));
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

// ════════════════════════════════════════
//  رسّام الورقة المستقل
// ════════════════════════════════════════
class _LeafPainter extends CustomPainter {
  final LeafModel leaf;
  _LeafPainter({required this.leaf});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.translate(cx, cy);

    final w = leaf.width;
    final h = leaf.height;
    final baseColor = Color(leaf.color);
    final darkLeaf = _darken(baseColor, 0.3);
    final lightLeaf = _lighten(baseColor, 0.25);
    final midLeaf = _lighten(baseColor, 0.1);

    // تدرج لوني واقعي
    final gradient = LinearGradient(
      begin: const Alignment(-0.6, -1),
      end: const Alignment(0.6, 1),
      colors: [lightLeaf, midLeaf, darkLeaf],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(
        Rect.fromCenter(center: Offset.zero, width: w, height: h));

    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = darkLeaf.withOpacity(0.55)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    // ظل خفيف
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..style = PaintingStyle.fill;

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

    // ارسم الظل أولاً
    canvas.save();
    canvas.translate(2, 3);
    canvas.drawPath(leafPath, shadowPaint);
    canvas.restore();

    // الورقة
    canvas.drawPath(leafPath, fillPaint);
    canvas.drawPath(leafPath, strokePaint);

    // عروق الورقة
    _drawVeins(canvas, w, h, darkLeaf, leaf.style);

    // اسم الورقة
    if (leaf.name.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: leaf.name,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 8,
            color: Colors.white.withOpacity(0.92),
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 2)
            ],
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: w * 0.85);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    }
  }

  // ═══ أشكال الأوراق ═══

  Path _ovalLeaf(double w, double h) => Path()
    ..moveTo(0, -h / 2)
    ..cubicTo(w * 0.55, -h * 0.45, w * 0.55, h * 0.45, 0, h / 2)
    ..cubicTo(-w * 0.55, h * 0.45, -w * 0.55, -h * 0.45, 0, -h / 2);

  Path _pointedLeaf(double w, double h) => Path()
    ..moveTo(0, -h / 2)
    ..cubicTo(w * 0.58, -h * 0.12, w * 0.5, h * 0.28, 0, h / 2)
    ..cubicTo(-w * 0.5, h * 0.28, -w * 0.58, -h * 0.12, 0, -h / 2);

  Path _roundLeaf(double w, double h) => Path()
    ..addOval(Rect.fromCenter(center: Offset.zero, width: w, height: h * 0.88));

  Path _heartLeaf(double w, double h) {
    final path = Path();
    final s = w * 0.5;
    path.moveTo(0, h * 0.32);
    path.cubicTo(
        -s * 0.1, h * 0.08, -s, -h * 0.06, -s * 0.88, -h * 0.28);
    path.cubicTo(-s * 0.78, -h * 0.52, -s * 0.08, -h * 0.48, 0, -h * 0.18);
    path.cubicTo(s * 0.08, -h * 0.48, s * 0.78, -h * 0.52, s * 0.88, -h * 0.28);
    path.cubicTo(s, -h * 0.06, s * 0.1, h * 0.08, 0, h * 0.32);
    return path;
  }

  Path _mapleLeaf(double w, double h) {
    final path = Path();
    final r = w * 0.5;
    final ir = r * 0.36;
    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 5;
      final nextAngle = angle + math.pi / 5;
      if (i == 0) {
        path.moveTo(r * math.cos(angle), r * math.sin(angle));
      } else {
        path.lineTo(r * math.cos(angle), r * math.sin(angle));
      }
      path.lineTo(ir * math.cos(nextAngle), ir * math.sin(nextAngle));
    }
    path.close();
    return path;
  }

  Path _palmLeaf(double w, double h) => Path()
    ..moveTo(0, -h / 2)
    ..cubicTo(w * 0.65, -h * 0.28, w * 0.78, h * 0.12, w * 0.18, h / 2)
    ..cubicTo(0, h * 0.28, 0, h * 0.08, 0, 0)
    ..cubicTo(0, h * 0.08, 0, h * 0.28, -w * 0.18, h / 2)
    ..cubicTo(-w * 0.78, h * 0.12, -w * 0.65, -h * 0.28, 0, -h / 2);

  Path _featherLeaf(double w, double h) => Path()
    ..moveTo(0, -h / 2)
    ..cubicTo(w * 0.38, -h * 0.18, w * 0.28, h * 0.22, 0, h / 2)
    ..cubicTo(-w * 0.28, h * 0.22, -w * 0.38, -h * 0.18, 0, -h / 2);

  void _drawPineLeaf(
      Canvas canvas, double w, double h, Color base, Color dark) {
    final stemPaint = Paint()
      ..color = base
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, -h / 2), Offset(0, h / 2), stemPaint);

    for (int i = 1; i < 5; i++) {
      final y = -h / 2 + i * h / 5.0;
      final len = w * 0.42 * (1 - i * 0.08);
      final needlePaint = Paint()
        ..color = dark.withOpacity(0.75)
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
          Offset(0, y), Offset(len, y + len * 0.25), needlePaint);
      canvas.drawLine(
          Offset(0, y), Offset(-len, y + len * 0.25), needlePaint);
    }
  }

  // ═══ عروق الورقة الواقعية ═══
  void _drawVeins(
      Canvas canvas, double w, double h, Color dark, LeafStyle style) {
    if (style == LeafStyle.maple ||
        style == LeafStyle.pine ||
        style == LeafStyle.feather) return;

    final veinPaint = Paint()
      ..color = dark.withOpacity(0.3)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // العرق المركزي
    canvas.drawLine(
        Offset(0, -h * 0.44), Offset(0, h * 0.44), veinPaint);

    // عروق جانبية منحنية
    final sideCount = style == LeafStyle.palm ? 5 : 4;
    for (int i = 1; i <= sideCount; i++) {
      final t = i / (sideCount + 1);
      final y = -h * 0.4 + h * 0.8 * t;
      final xLen = w * 0.3 * math.sin(t * math.pi) * 0.9;
      final tipY = y - h * 0.05;

      // اليمين
      final rightPath = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(xLen * 0.6, tipY - h * 0.02, xLen, tipY);
      canvas.drawPath(
          rightPath, veinPaint..strokeWidth = 0.5..color = dark.withOpacity(0.22));

      // اليسار
      final leftPath = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(-xLen * 0.6, tipY - h * 0.02, -xLen, tipY);
      canvas.drawPath(
          leftPath, veinPaint..strokeWidth = 0.5..color = dark.withOpacity(0.22));
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
  bool shouldRepaint(covariant _LeafPainter old) => old.leaf != old.leaf;
}
