import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'onboarding_screen.dart';

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
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
            )
                .animate()
                .fadeIn(duration: 1200.ms)
                .scale(begin: const Offset(0.5, 0.5)),
            const SizedBox(height: 32),
            const Text(
              'سلالتي',
              style: TextStyle(
                fontSize: 48,
                fontFamily: 'Amiri',
                color: Color(0xFFFFD54F),
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0),
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
