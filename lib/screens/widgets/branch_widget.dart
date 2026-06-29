import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/tree_model.dart';

class BranchWidget extends StatelessWidget {
  final BranchModel branch;
  final bool isSelected;
  final VoidCallback onSelect;
  final Function(BranchModel) onUpdate;

  const BranchWidget({
    super.key, required this.branch, required this.isSelected,
    required this.onSelect, required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final cs = branch.length * 4;
    return Positioned(
      left: branch.x - cs / 2,
      top: branch.y - cs / 2,
      child: GestureDetector(
        onTap: branch.isLocked ? null : onSelect,
        onPanUpdate: branch.isLocked ? null : (d) => onUpdate(branch.copyWith(
          x: branch.x + d.delta.dx, y: branch.y + d.delta.dy,
        )),
        child: CustomPaint(
          size: Size(cs, cs),
          painter: BranchPainter(branch: branch, isSelected: isSelected),
        ),
      ),
    );
  }
}

class BranchPainter extends CustomPainter {
  final BranchModel branch;
  final bool isSelected;
  BranchPainter({required this.branch, required this.isSelected});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final endX = c.dx + branch.length * math.cos(branch.angle);
    final endY = c.dy - branch.length * math.sin(branch.angle);
    final end = Offset(endX, endY);

    final ctrlA = branch.angle + branch.curve;
    final ctrl = Offset(
      c.dx + branch.length * 0.5 * math.cos(ctrlA),
      c.dy - branch.length * 0.5 * math.sin(ctrlA),
    );

    final path = _buildPath(c, ctrl, end);

    // Glow
    if (isSelected) {
      canvas.drawPath(path, Paint()
        ..color = const Color(0xFFD4A55A).withOpacity(0.35)
        ..strokeWidth = branch.thickness + 12
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }

    // الغصن
    canvas.drawPath(path, Paint()
      ..shader = LinearGradient(
        colors: [Color(branch.color), Color(branch.color).withOpacity(0.75)],
      ).createShader(Rect.fromPoints(c, end))
      ..strokeWidth = branch.thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke);

    // الدائرة
    _drawHead(canvas, end);

    // الأوراق
    for (final leaf in branch.leaves) {
      _drawLeaf(canvas, Offset(end.dx + leaf.x, end.dy + leaf.y), leaf);
    }

    // قفل
    if (branch.isLocked) {
      final tp = TextPainter(
        text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 13)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - 22));
    }
  }

  Path _buildPath(Offset start, Offset ctrl, Offset end) {
    switch (branch.style) {
      case BranchStyle.straight:
        return Path()..moveTo(start.dx, start.dy)..lineTo(end.dx, end.dy);
      case BranchStyle.zigzag:
        final mid = Offset(
          (start.dx + end.dx) / 2 + branch.curve * 20,
          (start.dy + end.dy) / 2,
        );
        return Path()
          ..moveTo(start.dx, start.dy)
          ..lineTo(mid.dx, mid.dy)
          ..lineTo(end.dx, end.dy);
      case BranchStyle.vine:
        return Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(
            ctrl.dx - 10, ctrl.dy + 15,
            ctrl.dx + 10, ctrl.dy - 15,
            end.dx, end.dy,
          );
      default: // curved
        return Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    }
  }

  void _drawHead(Canvas canvas, Offset pos) {
    final r = branch.headRadius;
    // ظل
    canvas.drawCircle(pos, r, Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    // خلفية
    canvas.drawCircle(pos, r, Paint()
      ..color = const Color(0xFFFFF8E1)
      ..style = PaintingStyle.fill);
    // حافة
    canvas.drawCircle(pos, r, Paint()
      ..color = Color(branch.color)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke);

    if (branch.name.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: branch.name,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: (r * 0.52).clamp(8.0, 15.0),
            color: const Color(0xFF2A1A0A),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: r * 2.2);
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  void _drawLeaf(Canvas canvas, Offset pos, LeafModel leaf) {
    final w = leaf.width, h = leaf.height;
    final leafPath = _leafPath(pos, w, h, leaf.style);

    canvas.drawPath(leafPath, Paint()
      ..shader = LinearGradient(
        colors: [Color(leaf.color).withOpacity(0.9), Color(leaf.color)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
          Rect.fromCenter(center: pos, width: w, height: h))
      ..style = PaintingStyle.fill);

    canvas.drawPath(leafPath, Paint()
      ..color = Color(leaf.color).withOpacity(0.4)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke);

    if (leaf.name.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: leaf.name,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: (w * 0.28).clamp(7.0, 11.0),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
      )..layout(maxWidth: w);
      tp.paint(canvas,
          Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }
  }

  Path _leafPath(Offset c, double w, double h, LeafStyle style) {
    switch (style) {
      case LeafStyle.pointed:
        return Path()
          ..moveTo(c.dx, c.dy - h / 2)
          ..lineTo(c.dx + w / 2, c.dy)
          ..lineTo(c.dx, c.dy + h / 2)
          ..lineTo(c.dx - w / 2, c.dy)
          ..close();
      case LeafStyle.round:
        return Path()..addOval(
            Rect.fromCenter(center: c, width: w, height: h * 0.85));
      case LeafStyle.heart:
        final p = Path();
        p.moveTo(c.dx, c.dy + h * 0.3);
        p.cubicTo(c.dx - w * 0.6, c.dy, c.dx - w * 0.6, c.dy - h * 0.5,
            c.dx, c.dy - h * 0.2);
        p.cubicTo(c.dx + w * 0.6, c.dy - h * 0.5, c.dx + w * 0.6, c.dy,
            c.dx, c.dy + h * 0.3);
        return p;
      default: // oval
        return Path()
          ..moveTo(c.dx, c.dy - h / 2)
          ..quadraticBezierTo(c.dx + w / 2, c.dy, c.dx, c.dy + h / 2)
          ..quadraticBezierTo(c.dx - w / 2, c.dy, c.dx, c.dy - h / 2);
    }
  }

  @override
  bool shouldRepaint(covariant BranchPainter old) =>
      old.branch != branch || old.isSelected != isSelected;
}
