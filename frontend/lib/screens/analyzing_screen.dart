import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/photo_service.dart';
import '../models/analysis_result.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final PhotoData photo;
  final String mbti;

  const AnalyzingScreen({
    super.key,
    required this.photo,
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
  AnalysisResult? _apiResult;
  String? _apiError;
  bool _apiDone = false;

  final List<_Stage> _stages = [
    _Stage('얼굴형 & 이마 분석 중...', '인내심과 리더십의 지표를 읽고 있어요'),
    _Stage('눈매 & 눈썹 해석 중...', '감수성과 직관력의 창을 들여다봐요'),
    _Stage('코 & 입 특성 파악 중...', '의지력과 표현력의 흔적을 찾아요'),
    _Stage('MBTI 데이터와 결합 중...', '성격과 관상의 교차점을 계산해요'),
    _Stage('최적 직업을 매칭하는 중...', '수천 개의 직업 데이터와 대조 중이에요'),
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
        final stageIndex = (_progressController.value * _stages.length).floor();
        if (stageIndex != _currentStage && stageIndex < _stages.length) {
          setState(() => _currentStage = stageIndex);
          HapticFeedback.mediumImpact();
        }
      });

    _rotateController = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController.forward();
    _callApi();
    _cycleFunFacts();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        _tryNavigate();
      }
    });
  }

  Future<void> _callApi() async {
    try {
      final result = await ApiService.analyzePhoto(
        photoBytes: widget.photo.bytes,
        fileName: widget.photo.xFile.name,
        mbti: widget.mbti,
      );
      if (mounted) {
        setState(() { _apiResult = result; _apiDone = true; });
        if (_progressController.isCompleted) _tryNavigate();
      }
    } catch (e) {
      if (mounted) {
        setState(() { _apiError = e.toString(); _apiDone = true; });
        if (_progressController.isCompleted) _tryNavigate();
      }
    }
  }

  void _tryNavigate() {
    if (!_apiDone) return;

    if (_apiError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('분석 실패: $_apiError'),
            backgroundColor: Colors.red.shade700),
      );
      Navigator.of(context).pop();
      return;
    }

    if (_apiResult != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            photoBytes: widget.photo.bytes,
            mbti: widget.mbti,
            result: _apiResult,
          ),
        ),
      );
    }
  }

  void _cycleFunFacts() async {
    while (mounted && !_progressController.isCompleted) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) setState(() => _funFactIndex = (_funFactIndex + 1) % _funFacts.length);
    }
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
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_progressController, _rotateController, _pulseController]),
          builder: (context, _) {
            return Column(
              children: [
                const SizedBox(height: 48),
                _buildPhotoWithRings(),
                const SizedBox(height: 48),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    key: ValueKey(_currentStage),
                    children: [
                      Text(_stages[_currentStage].title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                              color: AppColors.ink),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text(_stages[_currentStage].subtitle,
                          style: TextStyle(fontSize: 14, color: AppColors.inkSecondary),
                          textAlign: TextAlign.center),
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
                              isDone ? Icons.check_circle
                                  : (isCurrent ? Icons.radio_button_on : Icons.radio_button_off),
                              size: 18,
                              color: isDone ? AppColors.success
                                  : (isCurrent ? AppColors.brandAmber : AppColors.inkTertiary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_stages[i].title.replaceAll('...', ''),
                                  style: TextStyle(fontSize: 13,
                                      color: isDone || isCurrent
                                          ? AppColors.ink : AppColors.inkTertiary,
                                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400)),
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
                          Text('분석 진행중',
                              style: TextStyle(fontSize: 12, color: AppColors.inkTertiary)),
                          Text('${(_progressController.value * 100).toInt()}%',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                  color: AppColors.brandAmber)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: AppColors.borderLight,
                          valueColor: const AlwaysStoppedAnimation(AppColors.ctaPrimary),
                          minHeight: 6,
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: AppColors.brandAmber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_funFacts[_funFactIndex],
                                style: TextStyle(fontSize: 12, color: AppColors.inkSecondary,
                                    height: 1.4)),
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
      width: 240, height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.05),
            child: Container(
              width: 230, height: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight, width: 1),
              ),
            ),
          ),
          Transform.rotate(
            angle: -_rotateController.value * 2 * pi,
            child: CustomPaint(size: const Size(210, 210),
                painter: _DashedCirclePainter(color: AppColors.inkTertiary.withValues(alpha: 0.4))),
          ),
          Transform.rotate(
            angle: _rotateController.value * 2 * pi,
            child: CustomPaint(size: const Size(190, 190),
                painter: _DashedCirclePainter(color: AppColors.brandAmber.withValues(alpha: 0.5))),
          ),
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderStrong, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24)],
            ),
            child: ClipOval(child: Image.memory(widget.photo.bytes, fit: BoxFit.cover)),
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
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    for (int i = 0; i < 36; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        (i * 2 * pi) / 36, pi / 36, false, paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Stage {
  final String title;
  final String subtitle;
  _Stage(this.title, this.subtitle);
}
