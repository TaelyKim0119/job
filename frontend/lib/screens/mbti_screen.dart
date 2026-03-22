import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';
import 'analyzing_screen.dart';

class MbtiScreen extends StatefulWidget {
  final File photoFile;

  const MbtiScreen({super.key, required this.photoFile});

  @override
  State<MbtiScreen> createState() => _MbtiScreenState();
}

class _MbtiScreenState extends State<MbtiScreen> {
  String? _selectedMbti;

  static const List<_MbtiType> _types = [
    // Analysts (NT)
    _MbtiType('INTJ', '전략가', AppColors.mbtiAnalyst),
    _MbtiType('INTP', '논리술사', AppColors.mbtiAnalyst),
    _MbtiType('ENTJ', '통솔자', AppColors.mbtiAnalyst),
    _MbtiType('ENTP', '변론가', AppColors.mbtiAnalyst),
    // Diplomats (NF)
    _MbtiType('INFJ', '옹호자', AppColors.mbtiDiplomat),
    _MbtiType('INFP', '중재자', AppColors.mbtiDiplomat),
    _MbtiType('ENFJ', '선도자', AppColors.mbtiDiplomat),
    _MbtiType('ENFP', '활동가', AppColors.mbtiDiplomat),
    // Sentinels (SJ)
    _MbtiType('ISTJ', '현실주의자', AppColors.mbtiSentinel),
    _MbtiType('ISFJ', '수호자', AppColors.mbtiSentinel),
    _MbtiType('ESTJ', '경영자', AppColors.mbtiSentinel),
    _MbtiType('ESFJ', '집정관', AppColors.mbtiSentinel),
    // Explorers (SP)
    _MbtiType('ISTP', '장인', AppColors.mbtiExplorer),
    _MbtiType('ISFP', '모험가', AppColors.mbtiExplorer),
    _MbtiType('ESTP', '사업가', AppColors.mbtiExplorer),
    _MbtiType('ESFP', '연예인', AppColors.mbtiExplorer),
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
            photoFile: widget.photoFile,
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
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('성격유형 선택'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                '당신의 성격유형은?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'MBTI를 모른다면 직관적으로 골라보세요',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // MBTI Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _types.length,
                  itemBuilder: (context, index) {
                    final type = _types[index];
                    final isSelected = _selectedMbti == type.code;
                    return _MbtiCell(
                      type: type,
                      isSelected: isSelected,
                      onTap: () => _onSelect(type.code),
                    );
                  },
                ),
              ),

              // Selected info card
              if (selected != null) ...[
                GlassCard(
                  borderColor: selected.color.withValues(alpha: 0.5),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${selected.code} — ${selected.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // CTA
              GoldButton(
                text: '분석 시작하기',
                icon: Icons.auto_awesome,
                onPressed: _selectedMbti != null ? _goNext : () {},
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

  const _MbtiCell({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.elevated : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.goldWarm : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.goldWarm.withValues(alpha: 0.25),
                    blurRadius: 12,
                  )
                ]
              : null,
        ),
        transform: isSelected
            ? (Matrix4.identity()..scale(1.04))
            : Matrix4.identity(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: type.color.withValues(alpha: isSelected ? 1.0 : 0.4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              type.code,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.goldLight
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type.name,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
