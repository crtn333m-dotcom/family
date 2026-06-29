import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'projects_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _page = 0;

  final _pages = const [
    _SplashPage(
      emoji: '🌱',
      title: 'مرحباً بك في سلالتي',
      subtitle: 'ابنِ شجرة نسبك بطريقة بصرية احترافية',
    ),
    _SplashPage(
      emoji: '🌿',
      title: 'أضف جذعاً وأغصاناً',
      subtitle: 'كل غصن يمثل فرداً أو فرعاً من عائلتك',
    ),
    _SplashPage(
      emoji: '🌳',
      title: 'صدّر وشارك شجرتك',
      subtitle: 'احفظ شجرتك كصورة وشاركها مع عائلتك',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0C0C0C) : const Color(0xFFF4F0EA);
    final accent = const Color(0xFFD4A55A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView.builder(
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => _pages[i],
            ),
          ),
          // Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _page == i ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _page == i ? accent : accent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
          const SizedBox(height: 32),
          // زر البدء
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProjectsScreen()),
                ),
                child: Text(
                  _page == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
                  style: const TextStyle(
                      fontFamily: 'Amiri', fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

class _SplashPage extends StatelessWidget {
  final String emoji, title, subtitle;
  const _SplashPage({
    required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF2EDE6) : const Color(0xFF18120A);

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 96))
              .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri', fontSize: 28,
              fontWeight: FontWeight.bold, color: textColor,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
          const SizedBox(height: 16),
          Text(subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri', fontSize: 16,
              color: textColor.withOpacity(0.6), height: 1.6,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}
