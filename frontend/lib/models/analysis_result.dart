class FaceFeatures {
  final String forehead;
  final String eyes;
  final String nose;
  final String mouth;
  final String jawline;
  final String faceShape;
  final String personalitySummary;

  FaceFeatures({
    required this.forehead,
    required this.eyes,
    required this.nose,
    required this.mouth,
    required this.jawline,
    required this.faceShape,
    required this.personalitySummary,
  });

  factory FaceFeatures.fromJson(Map<String, dynamic> json) {
    return FaceFeatures(
      forehead: json['forehead'] ?? '',
      eyes: json['eyes'] ?? '',
      nose: json['nose'] ?? '',
      mouth: json['mouth'] ?? '',
      jawline: json['jawline'] ?? '',
      faceShape: json['face_shape'] ?? '',
      personalitySummary: json['personality_summary'] ?? '',
    );
  }

  List<String> get keywords {
    final kw = <String>[];
    if (faceShape.isNotEmpty) kw.add(faceShape);
    if (forehead.contains('넓')) kw.add('넓은 이마');
    if (eyes.contains('예리') || eyes.contains('날카')) kw.add('예리한 눈매');
    if (eyes.contains('크') || eyes.contains('큰')) kw.add('큰 눈');
    if (nose.contains('높') || nose.contains('의지')) kw.add('의지형 코');
    if (jawline.contains('강') || jawline.contains('각')) kw.add('강한 턱선');
    if (mouth.contains('올라') || mouth.contains('미소')) kw.add('미소형 입');
    if (kw.length < 3) {
      if (!kw.contains('넓은 이마')) kw.add('균형잡힌 이마');
      if (!kw.contains('예리한 눈매')) kw.add('부드러운 눈매');
    }
    return kw.take(4).toList();
  }
}

class JobRecommendation {
  final int rank;
  final String jobName;
  final String jobNameEn;
  final String description;
  final String faceReason;
  final String mbtiReason;
  final int matchScore;
  final List<String> skills;
  final String salaryRange;
  final String? generatedImageUrl;

  JobRecommendation({
    required this.rank,
    required this.jobName,
    required this.jobNameEn,
    required this.description,
    required this.faceReason,
    required this.mbtiReason,
    required this.matchScore,
    required this.skills,
    required this.salaryRange,
    this.generatedImageUrl,
  });

  factory JobRecommendation.fromJson(Map<String, dynamic> json) {
    return JobRecommendation(
      rank: json['rank'] ?? 0,
      jobName: json['job_name'] ?? '',
      jobNameEn: json['job_name_en'] ?? '',
      description: json['description'] ?? '',
      faceReason: json['face_reason'] ?? '',
      mbtiReason: json['mbti_reason'] ?? '',
      matchScore: json['match_score'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      salaryRange: json['salary_range'] ?? '',
      generatedImageUrl: json['generated_image_url'],
    );
  }
}

class AnalysisResult {
  final String analysisId;
  final FaceFeatures faceFeatures;
  final String mbti;
  final String mbtiDescription;
  final List<JobRecommendation> recommendations;

  AnalysisResult({
    required this.analysisId,
    required this.faceFeatures,
    required this.mbti,
    required this.mbtiDescription,
    required this.recommendations,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      analysisId: json['analysis_id'] ?? '',
      faceFeatures: FaceFeatures.fromJson(json['face_features'] ?? {}),
      mbti: json['mbti'] ?? '',
      mbtiDescription: json['mbti_description'] ?? '',
      recommendations: (json['recommendations'] as List? ?? [])
          .map((e) => JobRecommendation.fromJson(e))
          .toList(),
    );
  }
}
