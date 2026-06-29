import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ── Tokens ──────────────────────────────
  static const accent      = Color(0xFFD4A55A);
  static const accentDeep  = Color(0xFFB8863C);
  static const accentLight = Color(0xFFE8C47A);

  // Dark
  static const dBg      = Color(0xFF0C0C0C);
  static const dSurface = Color(0xFF141414);
  static const dCard    = Color(0xFF1C1C1C);
  static const dBorder  = Color(0xFF272727);
  static const dText    = Color(0xFFF2EDE6);
  static const dTextSec = Color(0xFF7A6E62);

  // Light
  static const lBg      = Color(0xFFF4F0EA);
  static const lSurface = Color(0xFFFFFFFF);
  static const lCard    = Color(0xFFFAF6F0);
  static const lBorder  = Color(0xFFE4D9CC);
  static const lText    = Color(0xFF18120A);
  static const lTextSec = Color(0xFF8A7A6A);

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    return ThemeData(
      brightness: b,
      fontFamily: 'Amiri',
      scaffoldBackgroundColor: isDark ? dBg : lBg,
      colorScheme: ColorScheme(
        brightness: b,
        primary: accent,
        onPrimary: Colors.white,
        secondary: accentLight,
        onSecondary: Colors.white,
        error: const Color(0xFFCF6679),
        onError: Colors.white,
        surface: isDark ? dSurface : lSurface,
        onSurface: isDark ? dText : lText,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? dSurface : lSurface,
        foregroundColor: isDark ? dText : lText,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Amiri', fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? dText : lText,
        ),
      ),
      cardColor: isDark ? dCard : lCard,
      dividerColor: isDark ? dBorder : lBorder,
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
        thumbColor: accent,
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
    );
  }
}
