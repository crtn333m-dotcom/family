import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3E2723),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              size: const Size(200, 250),
              painter: SplashTreePainter(),
            ).animate().fadeIn(duration: 1200.ms).scale(
                  begin: const Offset(0.5, 0.5),
                ),
            const SizedBox(height: 32),
            const Text(
              'سلالتي',
              style: TextStyle(
                fontSize: 48,
                fontFamily: 'Amiri',
                color: Color(0xFFFFD54F),
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(
                  begin: 0.3,
                  end: 0,
                ),
            const SizedBox(height: 12),
            const Text(
              'اكتشف جذورك وابنِ شجرتك',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Amiri',
                color: Color(0xFFA5D6A7),
              ),
            ).animate().fadeIn(delay: 1000.ms, duration: 800.ms),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: Color(0xFFFFD54F),
              strokeWidth: 2,
            ).animate().fadeIn(delay: 1500.ms),
          ],
        ),
      ),
    );
  }
}

class SplashTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF6D4C41)
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final branchPaint = Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final leafPaint = Paint()
      ..color = const Color(0xFF388E3C)
      ..style = PaintingStyle.fill;

    final trunkPath = Path()
      ..moveTo(size.width / 2, size.height)
      ..quadraticBezierTo(
        size.width / 2 + 10,
        size.height * 0.6,
        size.width / 2,
        size.height * 0.4,
      );
    canvas.drawPath(trunkPath, trunkPaint);

    for (final isLeft in [true, false]) {
      final direction = isLeft ? -1.0 : 1.0;
      final startX = size.width / 2;
      final startY = size.height * 0.5;

      final branch1 = Path()
        ..moveTo(startX, startY)
        ..quadraticBezierTo(
          startX + direction * 40,
          startY - 30,
          startX + direction * 70,
          startY - 60,
        );
      canvas.drawPath(branch1, branchPaint);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(startX + direction * 75, startY - 70),
          width: 35,
          height: 50,
        ),
        leafPaint,
      );

      final branch2 = Path()
        ..moveTo(startX, size.height * 0.35)
        ..quadraticBezierTo(
          startX + direction * 55,
          size.height * 0.25,
          startX + direction * 85,
          size.height * 0.15,
        );
      canvas.drawPath(branch2, branchPaint);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(startX + direction * 90, size.height * 0.1),
          width: 30,
          height: 45,
        ),
        leafPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
