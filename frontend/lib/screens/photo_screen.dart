import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';
import '../services/photo_service.dart';
import 'mbti_screen.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  PhotoData? _photo;

  Future<void> _takePhoto() async {
    final photo = await PhotoService.takePhoto();
    if (photo != null) setState(() => _photo = photo);
  }

  Future<void> _pickFromGallery() async {
    final photo = await PhotoService.pickFromGallery();
    if (photo != null) setState(() => _photo = photo);
  }

  void _goNext() {
    if (_photo != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MbtiScreen(photo: _photo!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('사진 선택',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Step indicator
              Row(
                children: [
                  _StepDot(isActive: true, label: '1'),
                  Expanded(child: Container(height: 1, color: AppColors.borderLight)),
                  _StepDot(isActive: false, label: '2'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('사진 선택',
                      style: TextStyle(fontSize: 12, color: AppColors.brandAmber,
                          fontWeight: FontWeight.w600)),
                  Text('MBTI 선택',
                      style: TextStyle(fontSize: 12, color: AppColors.inkTertiary)),
                ],
              ),
              const SizedBox(height: 32),
              Expanded(
                child: _photo != null ? _buildPreview() : _buildPhotoOptions(),
              ),
              if (_photo != null) ...[
                const SizedBox(height: 16),
                GoldButton(text: '다음으로', icon: Icons.arrow_forward, onPressed: _goNext),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOptions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _pickFromGallery,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderStrong, width: 2),
              color: AppColors.surfaceLight,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_rounded, size: 48, color: AppColors.brandAmber),
                const SizedBox(height: 12),
                Text('사진 선택',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('갤러리에서 골라주세요',
                    style: TextStyle(fontSize: 12, color: AppColors.inkTertiary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: _takePhoto,
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('카메라로 촬영'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.inkSecondary,
            side: const BorderSide(color: AppColors.borderLight),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 32),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.brandAmber, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text('정면 사진이 가장 정확한 분석 결과를 제공합니다',
                    style: TextStyle(fontSize: 13, color: AppColors.inkSecondary)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.surfaceLight),
                Image.memory(_photo!.bytes, fit: BoxFit.contain),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.success, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Positioned(
                  bottom: 16, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text('사진 준비 완료',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                                  color: AppColors.success)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _photo = null),
          child: Text('다시 선택하기', style: TextStyle(color: AppColors.inkTertiary)),
        ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool isActive;
  final String label;
  const _StepDot({required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.ctaPrimary : AppColors.surfaceLight,
        border: Border.all(color: isActive ? AppColors.ctaPrimary : AppColors.borderLight),
      ),
      child: Center(
        child: Text(label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: isActive ? AppColors.inkInverted : AppColors.inkTertiary)),
      ),
    );
  }
}
