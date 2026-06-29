import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/projects_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SulalatiApp());
}

class SulalatiApp extends StatelessWidget {
  const SulalatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سلالتي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Amiri',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5D4037),
          primary: const Color(0xFF5D4037),
          secondary: const Color(0xFF388E3C),
          surface: const Color(0xFFFFF8E1),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8E1),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF5D4037),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/projects': (context) => const ProjectsScreen(),
      },
    );
  }
}
