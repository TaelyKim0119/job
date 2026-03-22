import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/gold_button.dart';
import '../widgets/glass_card.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      tag: 'FACE READING',
      tagColor: AppColors.goldWarm,
      icon: Icons.face_retouching_natural,
      title: '얼굴이 말해주는\n당신의 가능성',
      subtitle: '이마의 폭, 눈썹의 각도, 코의 형태 —\n관상학이 발견한 당신만의 직업 DNA',
      gradientColors: [AppColors.purpleDeep, AppColors.void_],
    ),
    _OnboardingData(
      tag: 'MBTI SYNTHESIS',
      tagColor: AppColors.goldWarm,
      icon: Icons.psychology_rounded,
      title: '성격유형이 만드는\n완벽한 직업 궁합',
      subtitle: 'INTJ의 전략적 사고 + 당신의 리더형 인상 =\n어울리는 직업이 보이기 시작합니다',
      gradientColors: [AppColors.purpleMid, AppColors.void_],
    ),
    _OnboardingData(
      tag: 'JUST FOR FUN',
      tagColor: AppColors.info,
      icon: Icons.auto_awesome,
      title: '진지하게,\n하지만 즐겁게',
      subtitle: '직감은 과학적 직업 진단이 아닌\n관상학적 재미 분석입니다',
      gradientColors: [AppColors.purpleDeep, AppColors.void_],
      showDisclaimer: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SafeArea(
        child: Stack(
          children: [
            // Pages
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return _buildPage(page);
              },
            ),
            // Skip button
            if (_currentPage < _pages.length - 1)
              Positioned(
                top: 8,
                right: 20,
                child: TextButton(
                  onPressed: _goToHome,
                  child: Text(
                    '건너뛰기',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            // Bottom area
            Positioned(
              left: 20,
              right: 20,
              bottom: 32,
              child: Column(
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.goldWarm
                              : AppColors.textTertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Button
                  GoldButton(
                    text: _currentPage == _pages.length - 1
                        ? '직감 시작하기'
                        : '다음',
                    onPressed: _nextPage,
                    icon: _currentPage == _pages.length - 1
                        ? Icons.auto_awesome
                        : Icons.arrow_forward,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingData page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Visual area (top 50%)
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: page.gradientColors,
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Icon(
                  page.icon,
                  size: 100,
                  color: AppColors.goldWarm.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          // Content area (bottom 50%)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                // Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: page.tagColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    page.tag,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: page.tagColor,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  page.subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                // Disclaimer
                if (page.showDisclaimer) ...[
                  const SizedBox(height: 24),
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          color: AppColors.warning,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '재미를 위한 분석으로, 실제 취업이나\n진로 결정에 영향을 미치지 않습니다',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String tag;
  final Color tagColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final bool showDisclaimer;

  _OnboardingData({
    required this.tag,
    required this.tagColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    this.showDisclaimer = false,
  });
}
