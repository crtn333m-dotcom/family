import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'projects_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C1810),
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: const [
              _Page1(),
              _Page2(),
              _Page3(),
            ],
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? const Color(0xFFFFD54F)
                            : const Color(0xFF6D4C41),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD54F),
                        foregroundColor: const Color(0xFF2C1810),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage < 2) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProjectsScreen(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        _currentPage < 2 ? 'التالي ←' : 'ابدأ رحلتك 🌳',
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Amiri',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Page1 extends StatelessWidget {
  const _Page1();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B0000), Color(0xFF4A1942)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '﴿',
                style: TextStyle(fontSize: 60, color: Color(0xFFFFD54F)),
              ).animate().fadeIn(duration: 800.ms),
              const SizedBox(height: 24),
              const Text(
                'يَا أَيُّهَا النَّاسُ إِنَّا خَلَقْنَاكُم مِّن ذَكَرٍ وَأُنثَىٰ وَجَعَلْنَاكُمْ شُعُوبًا وَقَبَائِلَ لِتَعَارَفُوا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Amiri',
                  color: Color(0xFFFFF8E1),
                  height: 2,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
              const SizedBox(height: 20),
              const Text(
                '— سورة الحجرات، آية ١٣',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Amiri',
                  color: Color(0xFFFFD54F),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _Page2 extends StatelessWidget {
  const _Page2();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2F1A), Color(0xFF2E5D2E)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 80, 32, 120),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '❝',
                style: TextStyle(fontSize: 60, color: Color(0xFFFFD54F)),
              ).animate().fadeIn(duration: 800.ms),
              const SizedBox(height: 24),
              const Text(
                'تعلَّموا من أنسابكم ما تصلون به أرحامكم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Amiri',
                  color: Color(0xFFFFF8E1),
                  height: 2,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFFD54F), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'حديث شريف',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Amiri',
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _Page3 extends StatelessWidget {
  const _Page3();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C1810), Color(0xFF5D4037)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 60, 32, 120),
          child: Column(
            children: [
              const Text(
                'إهداء',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Amiri',
                  color: Color(0xFFFFD54F),
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 600.ms),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 2,
                color: const Color(0xFFFFD54F),
              ),
              const SizedBox(height: 32),
              const Text(
                'إلى من سبقوني إلى الوجود فكانوا سبب وجودي...\n\n'
                'الأب.. ظلٌّ لا تراه العين لكن تحسّه الروح\n'
                'الأم.. وطنٌ يحمله الإنسان بداخله أينما رحل\n\n'
                'نحن لسنا أفراداً جئنا من العدم،\n'
                'بل امتدادٌ لأرواح أحبّت قبلنا\n'
                'وزرعت فينا ما لم تزرعه الكلمات.\n\n'
                'هذا العمل.. ثمرة شجرة غرستموها أنتم.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Amiri',
                  color: Color(0xFFFFF8E1),
                  height: 2,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 1000.ms),
              const SizedBox(height: 24),
              const Text(
                '— حسين الدخيل',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Amiri',
                  color: Color(0xFFFFD54F),
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(delay: 1200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
