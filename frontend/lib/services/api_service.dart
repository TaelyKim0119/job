import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/analysis_result.dart';

class ApiService {
  // 웹에서는 localhost 직접 사용
  static const String _baseUrl = 'http://localhost:8000';

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

  /// 사진 바이트 + MBTI로 분석 요청
  static Future<AnalysisResult> analyzePhoto({
    required Uint8List photoBytes,
    required String fileName,
    required String mbti,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/analysis/upload-and-analyze');

    // 파일 확장자에서 content type 추론
    final ext = fileName.split('.').last.toLowerCase();
    final mimeType = switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    print('[ApiService] 요청 시작: $uri, MBTI=$mbti, 파일=$fileName, '
        '크기=${photoBytes.length}bytes, MIME=$mimeType');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['mbti'] = mbti
        ..files.add(http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ));

      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse);

      print('[ApiService] 응답 코드: ${response.statusCode}');
      print('[ApiService] 응답 본문: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        return AnalysisResult.fromJson(json);
      } else {
        String errorMsg = '분석 중 오류가 발생했습니다';
        try {
          final error = jsonDecode(utf8.decode(response.bodyBytes));
          errorMsg = error['detail'] ?? errorMsg;
        } catch (_) {
          errorMsg = response.body;
        }
        throw ApiException(
          statusCode: response.statusCode,
          message: errorMsg,
        );
      }
    } catch (e) {
      print('[ApiService] 에러 발생: $e');
      rethrow;
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
