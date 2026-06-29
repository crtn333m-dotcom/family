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
    return Positioned(
      left: trunk.x - trunk.thickness / 2,
      top: trunk.y - trunk.height,
      child: GestureDetector(
        onTap: trunk.isLocked ? null : onSelect,
        onPanUpdate: trunk.isLocked
            ? null
            : (d) => onUpdate(TrunkModel(
                  id: trunk.id,
                  x: trunk.x + d.delta.dx,
                  y: trunk.y + d.delta.dy,
                  names: trunk.names,
                  height: trunk.height,
                  thickness: trunk.thickness,
                  isLocked: trunk.isLocked,
                  branches: trunk.branches,
                )),
        child: CustomPaint(
          size: Size(trunk.thickness * 3, trunk.height),
          painter: TrunkPainter(
            trunk: trunk,
            isSelected: isSelected,
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
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xFF4E342E),
          const Color(0xFF8D6E63),
          const Color(0xFF4E342E),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = trunk.thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..quadraticBezierTo(
        size.width / 2 + 8,
        size.height * 0.5,
        size.width / 2,
        0,
      );

    canvas.drawPath(path, paint);

    if (isSelected) {
      final selectPaint = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.5)
        ..strokeWidth = trunk.thickness + 8
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, selectPaint);
    }

    // الأسماء داخل الجذع
    for (int i = 0; i < trunk.names.length && i < 20; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: trunk.names[i],
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 10,
            color: const Color(0xFFFFF8E1).withOpacity(0.9),
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout(maxWidth: trunk.thickness * 2);

      final y = size.height * 0.8 - (i * (size.height * 0.7 / 20));
      textPainter.paint(
        canvas,
        Offset(size.width / 2 - textPainter.width / 2, y),
      );
    }

    // قفل
    if (trunk.isLocked) {
      final iconPainter = TextPainter(
        text: const TextSpan(text: '🔒', style: TextStyle(fontSize: 16)),
        textDirection: TextDirection.ltr,
      )..layout();
      iconPainter.paint(canvas, Offset(size.width / 2 - 8, -20));
    }
  }

  @override
  bool shouldRepaint(covariant TrunkPainter old) =>
      old.trunk != trunk || old.isSelected != isSelected;
}
