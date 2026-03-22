import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';
import '../services/photo_service.dart';
import 'analyzing_screen.dart';

class MbtiScreen extends StatefulWidget {
  final PhotoData photo;

  const MbtiScreen({super.key, required this.photo});

  @override
  State<MbtiScreen> createState() => _MbtiScreenState();
}

class _MbtiScreenState extends State<MbtiScreen> {
  String? _selectedMbti;

  // I(내향) = 파란 계열, E(외향) = 빨강 계열
  static const Color _introvertColor = Color(0xFF4A7FBF); // 차분한 파랑
  static const Color _extrovertColor = Color(0xFFD94F4F); // 활발한 빨강

  static const List<_MbtiType> _types = [
    _MbtiType('INTJ', '전략가', _introvertColor),
    _MbtiType('INTP', '논리술사', _introvertColor),
    _MbtiType('ENTJ', '통솔자', _extrovertColor),
    _MbtiType('ENTP', '변론가', _extrovertColor),
    _MbtiType('INFJ', '옹호자', _introvertColor),
    _MbtiType('INFP', '중재자', _introvertColor),
    _MbtiType('ENFJ', '선도자', _extrovertColor),
    _MbtiType('ENFP', '활동가', _extrovertColor),
    _MbtiType('ISTJ', '현실주의자', _introvertColor),
    _MbtiType('ISFJ', '수호자', _introvertColor),
    _MbtiType('ESTJ', '경영자', _extrovertColor),
    _MbtiType('ESFJ', '집정관', _extrovertColor),
    _MbtiType('ISTP', '장인', _introvertColor),
    _MbtiType('ISFP', '모험가', _introvertColor),
    _MbtiType('ESTP', '사업가', _extrovertColor),
    _MbtiType('ESFP', '연예인', _extrovertColor),
  ];

  void _onSelect(String mbti) {
    HapticFeedback.lightImpact();
    setState(() => _selectedMbti = mbti);
  }

  void _goNext() {
    if (_selectedMbti != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AnalyzingScreen(
            photo: widget.photo,
            mbti: _selectedMbti!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedMbti != null
        ? _types.firstWhere((t) => t.code == _selectedMbti)
        : null;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('성격유형 선택',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('당신의 성격유형은?',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                      color: AppColors.ink, letterSpacing: -0.5)),
              const SizedBox(height: 8),
              Text('MBTI를 모른다면 직관적으로 골라보세요',
                  style: TextStyle(fontSize: 14, color: AppColors.inkSecondary)),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 6,
                    mainAxisSpacing: 6, childAspectRatio: 3.0,
                  ),
                  itemCount: _types.length,
                  itemBuilder: (context, index) {
                    final type = _types[index];
                    return _MbtiCell(
                      type: type,
                      isSelected: _selectedMbti == type.code,
                      onTap: () => _onSelect(type.code),
                    );
                  },
                ),
              ),
              if (selected != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected.color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected.color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(selected.code,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                              color: selected.color)),
                      const SizedBox(width: 10),
                      Text(selected.name,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                              color: selected.color.withValues(alpha: 0.7))),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              GestureDetector(
                onTap: _selectedMbti != null ? _goNext : null,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _selectedMbti != null ? AppColors.ctaPrimary : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('분석 시작하기',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                            color: _selectedMbti != null ? AppColors.inkInverted : AppColors.inkTertiary)),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18,
                          color: _selectedMbti != null ? AppColors.inkInverted : AppColors.inkTertiary),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _MbtiCell extends StatelessWidget {
  final _MbtiType type;
  final bool isSelected;
  final VoidCallback onTap;
  const _MbtiCell({required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? type.color : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? type.color : AppColors.borderLight, width: 1.5),
          boxShadow: isSelected
              ? [BoxShadow(color: type.color.withValues(alpha: 0.25), blurRadius: 8)]
              : null,
        ),
        transform: isSelected ? (Matrix4.identity()..scale(1.04)) : Matrix4.identity(),
        child: Center(
          child: Text(type.code,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : type.color,
                  letterSpacing: -0.3)),
        ),
      ),
    );
  }
}

class _MbtiType {
  final String code;
  final String name;
  final Color color;
  const _MbtiType(this.code, this.name, this.color);
}
