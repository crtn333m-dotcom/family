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
    return Positioned(
      left: branch.x - branch.length / 2,
      top: branch.y - branch.length / 2,
      child: GestureDetector(
        onTap: branch.isLocked ? null : onSelect,
        onPanUpdate: branch.isLocked
            ? null
            : (d) => onUpdate(BranchModel(
                  id: branch.id,
                  name: branch.name,
                  x: branch.x + d.delta.dx,
                  y: branch.y + d.delta.dy,
                  length: branch.length,
                  thickness: branch.thickness,
                  angle: branch.angle,
                  curve: branch.curve,
                  isLocked: branch.isLocked,
                  leaves: branch.leaves,
                )),
        child: Stack(
          children: [
            CustomPaint(
              size: Size(branch.length * 2, branch.length * 2),
              painter: BranchPainter(
                  branch: branch, isSelected: isSelected),
            ),
            // الأوراق
            ...branch.leaves.map((leaf) => Positioned(
                  left: branch.length + leaf.x,
                  top: branch.length + leaf.y,
                  child: _LeafWidget(leaf: leaf),
                )),
          ],
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
    final center = Offset(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color = const Color(0xFF795548)
      ..strokeWidth = branch.thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final endX = center.dx +
        branch.length * _cos(branch.angle);
    final endY = center.dy -
        branch.length * _sin(branch.angle);

    final ctrlX = center.dx +
        branch.length * 0.5 * _cos(branch.angle + branch.curve);
    final ctrlY = center.dy -
        branch.length * 0.5 * _sin(branch.angle + branch.curve);

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(ctrlX, ctrlY, endX, endY);

    if (isSelected) {
      canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFFD54F).withOpacity(0.4)
            ..strokeWidth = branch.thickness + 8
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke);
    }

    canvas.drawPath(path, paint);

    // دائرة في الرأس
    final circlePaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endX, endY), branch.thickness * 0.8, circlePaint);

    // اسم الغصن
    final textPainter = TextPainter(
      text: TextSpan(
        text: branch.name,
        style: const TextStyle(
            fontFamily: 'Amiri', fontSize: 11, color: Color(0xFF3E2723)),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    textPainter.paint(
        canvas, Offset(endX - textPainter.width / 2, endY + 10));

    if (branch.isLocked) {
      final iconPainter = TextPainter(
        text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 14)),
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(canvas, Offset(center.dx - 8, center.dy - 24));
    }
  }

  double _cos(double angle) => angle == 0 ? 1 : (angle * 3.14159 / 180 == 0 ? 1 : _cosRad(angle));
  double _sin(double angle) => _sinRad(angle);
  double _cosRad(double deg) {
    final rad = deg;
    return rad < 0
        ? -_sinRad(-rad - 1.5708)
        : _sinRad(1.5708 - rad);
  }
  double _sinRad(double rad) {
    double r = rad % 6.28318;
    if (r < 0) r += 6.28318;
    if (r < 1.5708) return r - r * r * r / 6;
    if (r < 3.14159) return _sinRad(3.14159 - r);
    if (r < 4.71239) return -_sinRad(r - 3.14159);
    return -_sinRad(6.28318 - r);
  }

  @override
  bool shouldRepaint(covariant BranchPainter old) =>
      old.branch != old.branch || old.isSelected != isSelected;
}

class _LeafWidget extends StatelessWidget {
  final LeafModel leaf;
  const _LeafWidget({required this.leaf});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(leaf.width, leaf.height),
      painter: _LeafPainter(leaf: leaf),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final LeafModel leaf;
  _LeafPainter({required this.leaf});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..quadraticBezierTo(size.width, size.height / 2,
          size.width / 2, size.height)
      ..quadraticBezierTo(0, size.height / 2, size.width / 2, 0);

    canvas.drawPath(path, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: leaf.name,
        style: const TextStyle(
            fontFamily: 'Amiri', fontSize: 9, color: Colors.white),
      ),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: size.width);
    textPainter.paint(
        canvas,
        Offset(size.width / 2 - textPainter.width / 2,
            size.height / 2 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => old.leaf != leaf;
}
