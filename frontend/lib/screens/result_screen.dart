import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../models/analysis_result.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final Uint8List photoBytes;
  final String mbti;
  final AnalysisResult? result;

  const ResultScreen({
    super.key,
    required this.photoBytes,
    required this.mbti,
    this.result,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryController;

  List<JobRecommendation> get _jobs =>
      widget.result?.recommendations ?? _demoJobs;
  FaceFeatures? get _face => widget.result?.faceFeatures;

  static final List<JobRecommendation> _demoJobs = [
    JobRecommendation(
      rank: 1,
      jobName: '향수 조향사',
      jobNameEn: 'Perfumer',
      description: '세계적인 향수 브랜드에서 새로운 향기를 개발하는 전문가',
      faceReason: '넓은 이마와 섬세한 눈매는 높은 감각적 민감성과 창의력을 나타냅니다.',
      mbtiReason: '깊은 내면 세계와 예술적 감수성은 향기라는 보이지 않는 예술을 창조하는 데 최적입니다.',
      matchScore: 94,
      skills: ['후각 민감성', '화학 지식', '창의력'],
      salaryRange: '4,000~8,000만원',
    ),
    JobRecommendation(
      rank: 2,
      jobName: '게임 사운드 디자이너',
      jobNameEn: 'Game Sound Designer',
      description: '게임 속 효과음과 배경 음악을 설계하고 구현하는 전문가',
      faceReason: '예리한 눈매와 균형 잡힌 턱선은 집중력과 분석력이 뛰어남을 보여줍니다.',
      mbtiReason: '독립적인 작업 스타일과 디테일에 대한 집착은 완벽한 사운드를 만들어내는 데 강점입니다.',
      matchScore: 87,
      skills: ['음향 편집', 'DAW 활용', '게임 엔진'],
      salaryRange: '3,500~6,000만원',
    ),
    JobRecommendation(
      rank: 3,
      jobName: '문화재 복원사',
      jobNameEn: 'Art Conservator',
      description: '손상된 문화재와 예술 작품을 원래 상태로 복원하는 전문가',
      faceReason: '강한 턱선과 안정적인 얼굴형은 인내심과 끈기를 나타냅니다.',
      mbtiReason: '꼼꼼하고 체계적인 성격은 문화재를 정확하게 복원하는 데 이상적인 조합입니다.',
      matchScore: 82,
      skills: ['미술사', '화학', '세밀한 수작업'],
      salaryRange: '3,000~5,000만원',
    ),
  ];

  static const _medalColors = [
    Color(0xFFB8860B),  // gold
    Color(0xFF78716C),  // silver
    Color(0xFFCD7F32),  // bronze
  ];

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
      backgroundColor: AppColors.canvas,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader()),
          SliverToBoxAdapter(child: _buildFaceSummary()),
          SliverToBoxAdapter(child: _buildJobGrid()),
          SliverToBoxAdapter(child: _buildBottomActions()),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    final keywords = _face?.keywords ?? ['분석 결과'];

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20, right: 20, bottom: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.inkSecondary),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.borderStrong, width: 2),
                ),
                child: ClipOval(
                  child: Image.memory(widget.photoBytes, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('당신의 직업 DNA',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                          color: AppColors.ink, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.brandAmberBg,
                      ),
                      child: Text(widget.mbti,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.brandAmberText)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: keywords.map((kw) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surfaceLight,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Text(kw, style: const TextStyle(fontSize: 12,
                  color: AppColors.inkSecondary)),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceSummary() {
    final summary = _face?.personalitySummary ??
        '관상 분석 결과가 여기에 표시됩니다. API를 연결하면 실제 분석 결과를 볼 수 있습니다.';
    final animalType = _face?.animalType ?? '';
    final animalDesc = _face?.animalDescription ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          if (animalType.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pets, color: AppColors.brandAmber, size: 20),
                      const SizedBox(width: 8),
                      Text('당신의 동물상',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.brandAmberBg,
                        ),
                        child: Text(animalType,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                              color: AppColors.brandAmberText)),
                      ),
                    ],
                  ),
                  if (animalDesc.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(animalDesc,
                      style: TextStyle(fontSize: 14, color: AppColors.inkSecondary,
                          height: 1.6)),
                  ],
                ],
              ),
            ),
          if (animalType.isNotEmpty) const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_quote_rounded, color: AppColors.brandAmber, size: 18),
                    const SizedBox(width: 8),
                    const Text('관상 분석 요약',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(summary,
                  style: TextStyle(fontSize: 14, color: AppColors.inkSecondary,
                      height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.work_outline_rounded, color: AppColors.brandAmber, size: 18),
              const SizedBox(width: 8),
              const Text('추천 직업 TOP 3',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 14),
          // 사진 + 설명 1행 3열
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(_jobs.length, (index) {
              final job = _jobs[index];
              final medalColor = _medalColors[index.clamp(0, 2)];
              final isFirst = index == 0;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 5,
                    right: index == _jobs.length - 1 ? 0 : 5,
                  ),
                  child: GestureDetector(
                    onTap: () => _showJobDetail(job, medalColor),
                    child: Column(
                      children: [
                        // 사진
                        Container(
                          decoration: isFirst ? BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFB8860B), width: 2.5),
                          ) : null,
                          child: AspectRatio(
                            aspectRatio: 0.75,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(isFirst ? 12 : 12),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (job.generatedImageUrl != null)
                                    _buildJobImage(
                                      job.generatedImageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                  else
                                    Container(
                                      color: AppColors.surfaceLight,
                                      child: const Center(
                                        child: Icon(Icons.image_outlined,
                                          size: 24, color: AppColors.inkTertiary),
                                      ),
                                    ),
                                  // 순위 뱃지
                                  Positioned(
                                    top: 6, left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: medalColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('#${job.rank}',
                                        style: const TextStyle(fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // 직업명
                        Text(job.jobName,
                          style: TextStyle(fontSize: isFirst ? 15 : 13,
                              fontWeight: FontWeight.w800, color: AppColors.ink),
                          textAlign: TextAlign.center,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(job.jobNameEn,
                          style: TextStyle(fontSize: 10, color: AppColors.inkTertiary),
                          textAlign: TextAlign.center,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        // 매칭률
                        Text('${job.matchScore}%',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w800, color: medalColor)),
                        const SizedBox(height: 6),
                        // 설명
                        Text(job.description,
                          style: TextStyle(fontSize: 11,
                              color: AppColors.inkSecondary, height: 1.5),
                          textAlign: TextAlign.center,
                          maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        // 스킬 태그
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: job.skills.take(3).map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppColors.surfaceLight,
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Text(s, style: const TextStyle(fontSize: 9,
                                color: AppColors.inkSecondary)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildJobImage(String url, {
    BoxFit? fit,
    double? width,
    double? height,
  }) {
    if (url.startsWith('data:')) {
      final base64Str = url.split(',').last;
      final bytes = base64Decode(base64Str);
      return Image.memory(
        Uint8List.fromList(bytes),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    } else {
      return Image.network(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 40, color: AppColors.inkTertiary),
          const SizedBox(height: 8),
          Text('AI 이미지 생성 영역',
            style: TextStyle(fontSize: 12, color: AppColors.inkTertiary)),
        ],
      ),
    );
  }

  void _showJobDetail(JobRecommendation job, Color medalColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderStrong,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (job.generatedImageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildJobImage(
                        job.generatedImageUrl!,
                        width: double.infinity,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (job.generatedImageUrl != null)
                    const SizedBox(height: 20),
                  Text(job.jobName,
                    style: const TextStyle(fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(job.jobNameEn,
                    style: TextStyle(fontSize: 14,
                        color: AppColors.inkTertiary)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('매칭률 ${job.matchScore}%',
                        style: TextStyle(fontSize: 14,
                            fontWeight: FontWeight.w700, color: medalColor)),
                      const SizedBox(width: 12),
                      Text('연봉 ${job.salaryRange}',
                        style: TextStyle(fontSize: 14,
                            color: AppColors.inkSecondary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _DetailSection(
                    icon: Icons.face,
                    title: '관상이 말하는 이유',
                    content: job.faceReason,
                  ),
                  const SizedBox(height: 20),
                  _DetailSection(
                    icon: Icons.psychology,
                    title: '${widget.mbti}와 맞는 이유',
                    content: job.mbtiReason,
                  ),
                  const SizedBox(height: 20),
                  _DetailSection(
                    icon: Icons.build_outlined,
                    title: '필요한 스킬',
                    content: job.skills.join(', '),
                  ),
                  const SizedBox(height: 32),
                  GoldButton(
                    text: '이 결과 공유하기',
                    icon: Icons.share,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
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
                    colors: [Color(0xFFF09433), Color(0xFFE6683C),
                             Color(0xFFDC2743), Color(0xFFCC2366),
                             Color(0xFFBC1888)],
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.inkSecondary,
              side: const BorderSide(color: AppColors.borderLight),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
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
            Icon(icon, size: 18, color: AppColors.brandAmber),
            const SizedBox(width: 8),
            Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
          ],
        ),
        const SizedBox(height: 8),
        Text(content,
          style: TextStyle(fontSize: 14, color: AppColors.inkSecondary,
              height: 1.6)),
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
            Text(label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.white)),
          ],
        ),
      ),
    );
  }
}
