import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
  ]);
  runApp(const SalatiApp());
}

class SalatiApp extends StatefulWidget {
  const SalatiApp({super.key});

  static SalatiAppState? of(BuildContext ctx) =>
      ctx.findAncestorStateOfType<SalatiAppState>();

  @override
  State<SalatiApp> createState() => SalatiAppState();
}

class SalatiAppState extends State<SalatiApp> {
  ThemeMode _mode = ThemeMode.dark;
  bool get isDark => _mode == ThemeMode.dark;

  void toggleTheme() => setState(
      () => _mode = isDark ? ThemeMode.light : ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سلالتي',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _mode,
      home: const SplashScreen(),
    );
  }
}
