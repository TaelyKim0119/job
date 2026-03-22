import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final File photoFile;
  final String mbti;

  const ResultScreen({
    super.key,
    required this.photoFile,
    required this.mbti,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;

  // Demo data - will be replaced by API response
  final List<_DemoJob> _jobs = [
    _DemoJob(
      rank: 1,
      name: '향수 조향사',
      nameEn: 'Perfumer',
      description: '세계적인 향수 브랜드에서 새로운 향기를 개발하는 전문가',
      faceReason: '넓은 이마와 섬세한 눈매는 높은 감각적 민감성과 창의력을 나타냅니다. '
          '관상학적으로 이러한 얼굴 특징은 미세한 차이를 구별하는 능력이 뛰어남을 의미합니다.',
      mbtiReason: '이 성격유형의 깊은 내면 세계와 예술적 감수성은 '
          '향기라는 보이지 않는 예술을 창조하는 데 최적입니다.',
      matchScore: 94,
      skills: ['후각 민감성', '화학 지식', '창의력'],
      salary: '4,000~8,000만원',
      medalColor: AppColors.goldWarm,
    ),
    _DemoJob(
      rank: 2,
      name: '게임 사운드 디자이너',
      nameEn: 'Game Sound Designer',
      description: '게임 속 효과음과 배경 음악을 설계하고 구현하는 전문가',
      faceReason: '예리한 눈매와 균형 잡힌 턱선은 집중력과 분석력이 뛰어남을 보여줍니다. '
          '사운드의 미세한 차이를 감지하고 조합하는 능력과 연결됩니다.',
      mbtiReason: '이 유형의 독립적인 작업 스타일과 디테일에 대한 집착은 '
          '완벽한 사운드를 만들어내는 데 큰 강점입니다.',
      matchScore: 87,
      skills: ['음향 편집', 'DAW 활용', '게임 엔진'],
      salary: '3,500~6,000만원',
      medalColor: AppColors.textSecondary,
    ),
    _DemoJob(
      rank: 3,
      name: '문화재 복원사',
      nameEn: 'Art Conservator',
      description: '손상된 문화재와 예술 작품을 원래 상태로 복원하는 전문가',
      faceReason: '강한 턱선과 안정적인 얼굴형은 인내심과 끈기를 나타냅니다. '
          '세밀한 작업을 장시간 수행할 수 있는 집중력의 관상학적 징후입니다.',
      mbtiReason: '꼼꼼하고 체계적인 성격은 역사적 가치를 지닌 문화재를 '
          '정확하게 복원하는 데 이상적인 조합입니다.',
      matchScore: 82,
      skills: ['미술사', '화학', '세밀한 수작업'],
      salary: '3,000~5,000만원',
      medalColor: AppColors.warning,
    ),
  ];

  final List<String> _faceKeywords = ['넓은 이마', '예리한 눈매', '의지형 코'];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
      backgroundColor: AppColors.void_,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(child: _buildHeroHeader()),
          // Face analysis summary
          SliverToBoxAdapter(child: _buildFaceSummary()),
          // Job cards
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildJobCard(_jobs[index], index);
              },
              childCount: _jobs.length,
            ),
          ),
          // Share & retry buttons
          SliverToBoxAdapter(child: _buildBottomActions()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.purpleDeep, AppColors.void_],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // User photo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldWarm, width: 2),
                ),
                child: ClipOval(
                  child: Image.file(widget.photoFile, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '당신의 직업 DNA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.goldWarm.withValues(alpha: 0.15),
                      ),
                      child: Text(
                        widget.mbti,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.goldWarm,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Face keywords
          Wrap(
            spacing: 8,
            children: _faceKeywords.map((kw) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.glassBg,
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  kw,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    color: AppColors.goldWarm, size: 18),
                const SizedBox(width: 8),
                const Text(
                  '관상 분석 요약',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '넓은 이마는 지적 호기심과 기획력이 강함을 나타내고, '
              '예리한 눈매는 관찰력과 분석력이 뛰어난 유형임을 보여줍니다. '
              '의지형 코는 목표를 향한 추진력이 있음을 의미합니다.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(_DemoJob job, int index) {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        final delay = index * 0.15;
        final progress = (_entryController.value - delay).clamp(0.0, 1.0);
        final curve = Curves.easeOutBack.transform(progress);

        return Transform.translate(
          offset: Offset(0, 40 * (1 - curve)),
          child: Opacity(
            opacity: progress,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: GestureDetector(
          onTap: () => _showJobDetail(job),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: job.rank == 1
                  ? Border.all(
                      color: AppColors.goldWarm.withValues(alpha: 0.4))
                  : null,
              boxShadow: job.rank == 1
                  ? [
                      BoxShadow(
                        color: AppColors.goldWarm.withValues(alpha: 0.1),
                        blurRadius: 24,
                      )
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Image placeholder
                Container(
                  height: job.rank == 1 ? 200 : 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.purpleDeep.withValues(alpha: 0.5),
                        AppColors.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 40, color: AppColors.textTertiary),
                            const SizedBox(height: 8),
                            Text(
                              'AI 이미지 생성 영역',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Rank badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: job.medalColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: job.medalColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            '#${job.rank}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: job.medalColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.name,
                        style: TextStyle(
                          fontSize: job.rank == 1 ? 24 : 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.nameEn,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Match score bar
                      Row(
                        children: [
                          Text(
                            '매칭률',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: job.matchScore / 100,
                                backgroundColor: AppColors.elevated,
                                valueColor: AlwaysStoppedAnimation(
                                    job.medalColor),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${job.matchScore}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: job.medalColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        job.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Skills
                      Wrap(
                        spacing: 6,
                        children: job.skills.map((s) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.elevated,
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJobDetail(_DemoJob job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Job title
                  Text(
                    job.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(job.nameEn,
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textTertiary)),
                  const SizedBox(height: 24),
                  // Face reason
                  _DetailSection(
                    icon: Icons.face,
                    title: '관상이 말하는 이유',
                    content: job.faceReason,
                  ),
                  const SizedBox(height: 20),
                  // MBTI reason
                  _DetailSection(
                    icon: Icons.psychology,
                    title: '${widget.mbti}와 맞는 이유',
                    content: job.mbtiReason,
                  ),
                  const SizedBox(height: 20),
                  // Salary
                  _DetailSection(
                    icon: Icons.payments_outlined,
                    title: '예상 연봉',
                    content: job.salary,
                  ),
                  const SizedBox(height: 32),
                  // Share
                  GoldButton(
                    text: '이 결과 공유하기',
                    icon: Icons.share,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // TODO: Implement share
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Share buttons
          Row(
            children: [
              Expanded(
                child: _ShareButton(
                  icon: Icons.chat_bubble,
                  label: '카카오톡',
                  color: const Color(0xFFFEE500),
                  textColor: Colors.black87,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShareButton(
                  icon: Icons.camera_alt,
                  label: '인스타그램',
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFF09433),
                      Color(0xFFE6683C),
                      Color(0xFFDC2743),
                      Color(0xFFCC2366),
                      Color(0xFFBC1888),
                    ],
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textTertiary,
              side: const BorderSide(color: AppColors.border),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('다시 분석하기'),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.goldWarm),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? textColor;
  final Gradient? gradient;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    this.color,
    this.textColor,
    this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor ?? Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoJob {
  final int rank;
  final String name;
  final String nameEn;
  final String description;
  final String faceReason;
  final String mbtiReason;
  final int matchScore;
  final List<String> skills;
  final String salary;
  final Color medalColor;

  _DemoJob({
    required this.rank,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.faceReason,
    required this.mbtiReason,
    required this.matchScore,
    required this.skills,
    required this.salary,
    required this.medalColor,
  });
}
