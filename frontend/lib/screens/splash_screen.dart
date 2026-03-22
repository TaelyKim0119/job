import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleOffset;
  late Animation<double> _glowOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.5, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.4, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    _titleOffset = Tween<Offset>(
      begin: const Offset(0, 12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.65, curve: Curves.easeOut),
      ),
    );

    _glowOpacity = Tween<double>(begin: 0, end: 0.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Background glow
              Center(
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.goldWarm
                            .withValues(alpha: _glowOpacity.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Logo & Text
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo icon
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.goldWarm,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.explore_rounded,
                            color: AppColors.goldWarm,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // App name
                    Transform.translate(
                      offset: _titleOffset.value,
                      child: Opacity(
                        opacity: _titleOpacity.value,
                        child: const Column(
                          children: [
                            Text(
                              '직감',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppColors.goldWarm,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '職 感',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                                color: AppColors.textTertiary,
                                letterSpacing: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
