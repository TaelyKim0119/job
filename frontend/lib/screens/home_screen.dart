import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/gold_button.dart';
import 'photo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.explore_rounded,
                    color: AppColors.goldWarm,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '직감',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.goldWarm,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.history,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline,
                        color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Hero Area
            Expanded(
              child: Stack(
                children: [
                  // Background gradient
                  Positioned.fill(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.purpleDeep,
                            AppColors.void_,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Glow effects
                  Positioned(
                    top: 60,
                    right: 40,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.goldWarm.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 120,
                    left: 20,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.purpleMid.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.goldWarm.withValues(alpha: 0.15),
                          ),
                          child: const Text(
                            '관상 x MBTI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldWarm,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Main text
                        const Text(
                          '나의\n직업 DNA를\n찾아봐',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.2,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '얼굴이 말해주는 숨겨진 직업,\nAI가 당신의 모습으로 보여드립니다',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // CTA
                        GoldButton(
                          text: '분석 시작하기',
                          icon: Icons.auto_awesome,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const PhotoScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
