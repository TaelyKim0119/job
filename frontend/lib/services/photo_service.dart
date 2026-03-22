import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

/// 크로스플랫폼 사진 서비스 (모바일 + 웹 호환)
class PhotoData {
  final XFile xFile;
  final Uint8List bytes;

  PhotoData({required this.xFile, required this.bytes});
}

class PhotoService {
  static final ImagePicker _picker = ImagePicker();

  static Future<PhotoData?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (photo == null) return null;
    final bytes = await photo.readAsBytes();
    return PhotoData(xFile: photo, bytes: bytes);
  }

  static Future<PhotoData?> pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (photo == null) return null;
    final bytes = await photo.readAsBytes();
    return PhotoData(xFile: photo, bytes: bytes);
  }
}
