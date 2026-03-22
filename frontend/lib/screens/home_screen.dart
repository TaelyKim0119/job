import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'photo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;

  static const _photosRow1 = [
    'assets/images/aiony-haust-3TLl_97HNJo-unsplash.jpg',
    'assets/images/erik-lucatero-d2MSDujJl2g-unsplash.jpg',
    'assets/images/jake-nackos-IF9TK5Uy-KI-unsplash.jpg',
  ];
  static const _photosRow2 = [
    'assets/images/albert-dera-ILip77SbmOE-unsplash.jpg',
    'assets/images/houcine-ncib-B4TjXnI0Y2c-unsplash.jpg',
    'assets/images/lucas-gouvea-aoEwuEH7YAs-unsplash.jpg',
  ];
  static const _photosRow3 = [
    'assets/images/alexander-krivitskiy-o7wiNx9x9OQ-unsplash.jpg',
    'assets/images/alyona-grishina-BBmi4nJjKk8-unsplash.jpg',
    'assets/images/ayo-ogunseinde-6W4F62sN_yI-unsplash.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHero(),
                    const SizedBox(height: 16),
                    _buildTrustBar(),
                    _buildHowItWorks(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.explore_rounded, color: AppColors.ink, size: 22),
          const SizedBox(width: 6),
          const Text('직감',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.ink, letterSpacing: -0.5)),
          const SizedBox(width: 4),
          Text('職感',
            style: TextStyle(fontSize: 11, color: AppColors.inkTertiary,
                fontWeight: FontWeight.w500)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.inkSecondary, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.inkSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          // 상단: 텍스트 + CTA
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 배지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.brandAmberBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('관상 × MBTI',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.brandAmberText, letterSpacing: 0.2)),
                    ),
                    const SizedBox(height: 16),
                    // 헤드라인
                    const Text('관상으로 찾는\n나의 직업 DNA',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        height: 1.2,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('얼굴과 성격이 말해주는 나만의 직업 적성',
                      style: TextStyle(fontSize: 14, color: AppColors.inkSecondary,
                          height: 1.5)),
                    const SizedBox(height: 20),
                    // CTA 버튼
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PhotoScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                        decoration: BoxDecoration(
                          color: AppColors.ctaPrimary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('지금 분석하기',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                                  color: AppColors.inkInverted, letterSpacing: -0.2)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: AppColors.inkInverted, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 하단: 포토 그리드 (3열 2행, 화면 꽉 채움)
          AnimatedBuilder(
            animation: _entryController,
            builder: (context, child) {
              final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _entryController,
                  curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
                ),
              );
              return FadeTransition(
                opacity: fade,
                child: Column(
                  children: [
                    // 1행: 3장
                    Row(
                      children: [
                        Expanded(child: _photoTile(_photosRow1[0])),
                        const SizedBox(width: 6),
                        Expanded(child: _photoTile(_photosRow1[1])),
                        const SizedBox(width: 6),
                        Expanded(child: _photoTile(_photosRow1[2])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 2행: 3장
                    Row(
                      children: [
                        Expanded(child: _photoTile(_photosRow2[0])),
                        const SizedBox(width: 6),
                        Expanded(child: _photoTile(_photosRow2[1])),
                        const SizedBox(width: 6),
                        Expanded(child: _photoTile(_photosRow2[2])),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 3행: 3장 (기존 스텝카드 사진)
                    Row(
                      children: [
                        Expanded(child: _photoTile(_photosRow3[0])),
                        const SizedBox(width: 6),
                        Expanded(child: _photoTile(_photosRow3[1])),
                        const SizedBox(width: 6),
                        Expanded(child: _photoTile(_photosRow3[2])),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _photoTile(String assetPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 0.75, // 세로형 인물 사진 비율
        child: Image.asset(assetPath, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.surfaceLight,
            child: const Icon(Icons.person, color: AppColors.inkTertiary),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statBadge('12,847명', '분석 완료'),
          _divider(),
          _statBadge('4.8★', '만족도'),
          _divider(),
          _statBadge('30초', '평균 소요'),
        ],
      ),
    );
  }

  Widget _statBadge(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
            color: AppColors.ink)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.inkTertiary)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 28, color: AppColors.borderLight);
  }

  Widget _buildHowItWorks() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('어떻게 작동하나요?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: AppColors.ink, letterSpacing: -0.3)),
          const SizedBox(height: 20),
          Row(
            children: [
              // Step 1
              Expanded(
                child: _stepCircle('1', '사진 촬영', Icons.camera_alt_outlined),
              ),
              // 화살표
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 18, color: AppColors.inkTertiary),
              ),
              // Step 2
              Expanded(
                child: _stepCircle('2', 'MBTI 입력', Icons.psychology_outlined),
              ),
              // 화살표
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Icon(Icons.arrow_forward_rounded,
                    size: 18, color: AppColors.inkTertiary),
              ),
              // Step 3
              Expanded(
                child: _stepCircle('3', '결과 확인', Icons.auto_awesome_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepCircle(String number, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceLight,
            border: Border.all(color: AppColors.borderLight, width: 1.5),
          ),
          child: Stack(
            children: [
              Center(child: Icon(icon, size: 24, color: AppColors.ink)),
              Positioned(
                top: 0, right: 0,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.ctaPrimary,
                  ),
                  child: Center(
                    child: Text(number,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                          color: AppColors.inkInverted)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: AppColors.ink)),
      ],
    );
  }
}
