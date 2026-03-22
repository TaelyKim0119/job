import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color void_ = Color(0xFF0A0A0F);
  static const Color deep = Color(0xFF111118);
  static const Color surface = Color(0xFF1A1A24);
  static const Color elevated = Color(0xFF22222E);
  static const Color border = Color(0xFF2E2E3E);

  // Accent - Gold
  static const Color goldWarm = Color(0xFFC9A84C);
  static const Color goldLight = Color(0xFFE8C87A);
  static const Color goldMuted = Color(0xFF8B6E30);

  // Accent - Purple
  static const Color purpleDeep = Color(0xFF3B2F6B);
  static const Color purpleMid = Color(0xFF6B4FA0);
  static const Color purpleGlow = Color(0xFF9B6FD0);

  // Semantic
  static const Color success = Color(0xFF4CAF7D);
  static const Color info = Color(0xFF5B9BD5);
  static const Color warning = Color(0xFFE8A44A);

  // Text
  static const Color textPrimary = Color(0xFFF0EDE8);
  static const Color textSecondary = Color(0xFFA09A8E);
  static const Color textTertiary = Color(0xFF5E5A54);

  // Glass
  static Color glassBg = Colors.white.withValues(alpha: 0.06);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);

  // MBTI Group Colors
  static const Color mbtiAnalyst = Color(0xFF5B9BD5);    // NT
  static const Color mbtiDiplomat = Color(0xFF9B6FD0);   // NF
  static const Color mbtiSentinel = Color(0xFF4CAF7D);   // SJ
  static const Color mbtiExplorer = Color(0xFFE8A44A);   // SP

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldWarm, purpleMid],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [purpleDeep, void_],
  );

  // ─── Light Theme (Tailwind-inspired) ───
  static const Color canvas = Color(0xFFFAFAF8);
  static const Color surfaceLight = Color(0xFFF4F3F0);
  static const Color borderLight = Color(0xFFE2DFD9);
  static const Color borderStrong = Color(0xFFC8C4BB);

  // Brand Amber
  static const Color brandAmber = Color(0xFFB8860B);
  static const Color brandAmberBg = Color(0xFFFEF3C7);
  static const Color brandAmberText = Color(0xFF92400E);

  // Light Text
  static const Color ink = Color(0xFF1C1917);
  static const Color inkSecondary = Color(0xFF78716C);
  static const Color inkTertiary = Color(0xFFA8A29E);
  static const Color inkInverted = Color(0xFFFAFAF8);

  // CTA
  static const Color ctaPrimary = Color(0xFF1C1917);
  static const Color ctaHover = Color(0xFF292524);
}
