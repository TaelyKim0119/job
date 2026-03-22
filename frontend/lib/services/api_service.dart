import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';

class ApiService {
  // Android 에뮬레이터: 10.0.2.2, iOS 시뮬레이터: localhost
  // 실제 디바이스: 컴퓨터의 로컬 IP 주소 사용
  static const String _baseUrl = 'http://10.0.2.2:8000';

  static String get baseUrl => _baseUrl;

  /// 서버 상태 확인
  static Future<bool> healthCheck() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/analysis/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 사진 업로드 + 관상/MBTI 분석 요청
  static Future<AnalysisResult> analyzePhoto({
    required File photoFile,
    required String mbti,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/analysis/upload-and-analyze');

    final request = http.MultipartRequest('POST', uri)
      ..fields['mbti'] = mbti
      ..files.add(await http.MultipartFile.fromPath(
        'photo',
        photoFile.path,
        filename: 'selfie.jpg',
      ));

    final streamedResponse =
        await request.send().timeout(const Duration(seconds: 120));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      return AnalysisResult.fromJson(json);
    } else {
      final error = jsonDecode(utf8.decode(response.bodyBytes));
      throw ApiException(
        statusCode: response.statusCode,
        message: error['detail'] ?? '분석 중 오류가 발생했습니다',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
