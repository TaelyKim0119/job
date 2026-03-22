import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final File photoFile;
  final String mbti;

  const AnalyzingScreen({
    super.key,
    required this.photoFile,
    required this.mbti,
  });

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _rotateController;
  late AnimationController _pulseController;

  int _currentStage = 0;
  int _funFactIndex = 0;

  final List<_Stage> _stages = [
    _Stage('얼굴형 & 이마 분석 중...', '인내심과 리더십의 지표를 읽고 있어요', Icons.face),
    _Stage('눈매 & 눈썹 해석 중...', '감수성과 직관력의 창을 들여다봐요', Icons.visibility),
    _Stage('코 & 입 특성 파악 중...', '의지력과 표현력의 흔적을 찾아요', Icons.tag_faces),
    _Stage('MBTI 데이터와 결합 중...', '성격과 관상의 교차점을 계산해요', Icons.psychology),
    _Stage('최적 직업을 매칭하는 중...', '수천 개의 직업 데이터와 대조 중이에요', Icons.work_outline),
  ];

  final List<String> _funFacts = [
    '관상학에서 넓은 이마는 지적 호기심이 강하다는 의미입니다',
    '눈꼬리가 위로 올라간 사람은 독립심이 강하다는 설이 있어요',
    '관상학에서 코는 재물운과 의지력을 나타낸다고 합니다',
    '얼굴형은 성격의 큰 틀을 결정한다고 관상학자들은 말합니다',
    '입꼬리가 올라간 사람은 긍정적인 리더십을 가졌다고 해요',
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(() {
        final stageIndex =
            (_progressController.value * _stages.length).floor();
        if (stageIndex != _currentStage && stageIndex < _stages.length) {
          setState(() => _currentStage = stageIndex);
          HapticFeedback.mediumImpact();
        }
      });

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Start analysis
    _progressController.forward();

    // Cycle fun facts
    _cycleFunFacts();

    // Navigate when done
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        _navigateToResult();
      }
    });
  }

  void _cycleFunFacts() async {
    while (mounted && !_progressController.isCompleted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _funFactIndex = (_funFactIndex + 1) % _funFacts.length;
        });
      }
    }
  }

  void _navigateToResult() {
    // TODO: Replace with actual API call result
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          photoFile: widget.photoFile,
          mbti: widget.mbti,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _progressController,
            _rotateController,
            _pulseController,
          ]),
          builder: (context, _) {
            return Column(
              children: [
                const SizedBox(height: 48),

                // Photo with animated rings
                _buildPhotoWithRings(),

                const SizedBox(height: 48),

                // Current stage text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    key: ValueKey(_currentStage),
                    children: [
                      Text(
                        _stages[_currentStage].title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stages[_currentStage].subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Stage checklist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: List.generate(_stages.length, (i) {
                      final isDone = i < _currentStage;
                      final isCurrent = i == _currentStage;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isDone
                                  ? Icons.check_circle
                                  : (isCurrent
                                      ? Icons.radio_button_on
                                      : Icons.radio_button_off),
                              size: 18,
                              color: isDone
                                  ? AppColors.success
                                  : (isCurrent
                                      ? AppColors.goldWarm
                                      : AppColors.textTertiary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _stages[i].title.replaceAll('...', ''),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDone || isCurrent
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                  fontWeight: isCurrent
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '분석 진행중',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          Text(
                            '${(_progressController.value * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.goldWarm,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: AppColors.surface,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.goldWarm,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Fun fact
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      key: ValueKey(_funFactIndex),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _funFacts[_funFactIndex],
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPhotoWithRings() {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring 3 - pulsing
          Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.05),
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
          ),
          // Outer ring 2 - rotating reverse
          Transform.rotate(
            angle: -_rotateController.value * 2 * pi,
            child: CustomPaint(
              size: const Size(210, 210),
              painter: _DashedCirclePainter(
                color: AppColors.purpleMid.withValues(alpha: 0.5),
              ),
            ),
          ),
          // Outer ring 1 - rotating
          Transform.rotate(
            angle: _rotateController.value * 2 * pi,
            child: CustomPaint(
              size: const Size(190, 190),
              painter: _DashedCirclePainter(
                color: AppColors.goldWarm.withValues(alpha: 0.7),
              ),
            ),
          ),
          // Photo
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldWarm.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.goldWarm.withValues(alpha: 0.2),
                  blurRadius: 24,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.file(
                widget.photoFile,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const dashCount = 36;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * pi) / dashCount;
      final sweepAngle = (pi) / dashCount;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Stage {
  final String title;
  final String subtitle;
  final IconData icon;

  _Stage(this.title, this.subtitle, this.icon);
}
