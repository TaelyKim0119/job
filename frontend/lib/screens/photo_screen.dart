import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/gold_button.dart';
import 'mbti_screen.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() => _selectedImage = File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() => _selectedImage = File(photo.path));
    }
  }

  void _goNext() {
    if (_selectedImage != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MbtiScreen(photoFile: _selectedImage!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.void_,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('사진 선택'),
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
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.border,
                    ),
                  ),
                  _StepDot(isActive: false, label: '2'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('사진 선택',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.goldWarm)),
                  Text('MBTI 선택',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textTertiary)),
                ],
              ),

              const SizedBox(height: 32),

              // Photo area
              Expanded(
                child: _selectedImage != null
                    ? _buildPreview()
                    : _buildPhotoOptions(),
              ),

              // Bottom button
              if (_selectedImage != null) ...[
                const SizedBox(height: 16),
                GoldButton(
                  text: '다음으로',
                  icon: Icons.arrow_forward,
                  onPressed: _goNext,
                ),
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
        // Camera option
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.goldWarm.withValues(alpha: 0.5),
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              color: AppColors.surface,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_rounded,
                    size: 48, color: AppColors.goldWarm),
                const SizedBox(height: 12),
                Text('셀피 촬영',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Gallery option
        OutlinedButton.icon(
          onPressed: _pickFromGallery,
          icon: const Icon(Icons.photo_library_rounded),
          label: const Text('갤러리에서 선택'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Tips
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '정면 사진이 가장 정확한 분석 결과를 제공합니다',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
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
        // Preview image
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
                // Scan overlay
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.7),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                // Check badge
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10,
                      ),
                      borderRadius: 20,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '사진 준비 완료',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.success,
                            ),
                          ),
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
          onPressed: () => setState(() => _selectedImage = null),
          child: Text(
            '다시 선택하기',
            style: TextStyle(color: AppColors.textTertiary),
          ),
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
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.goldWarm : AppColors.surface,
        border: Border.all(
          color: isActive ? AppColors.goldWarm : AppColors.border,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.void_ : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
