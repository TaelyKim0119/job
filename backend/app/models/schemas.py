from pydantic import BaseModel
from typing import Optional


class AnalysisRequest(BaseModel):
    """분석 요청: 사진 URL + MBTI"""
    photo_url: str
    mbti: str


class FaceFeatures(BaseModel):
    """관상 분석 결과"""
    forehead: str  # 이마 특성
    eyes: str  # 눈매 특성
    nose: str  # 코 특성
    mouth: str  # 입 특성
    jawline: str  # 턱선 특성
    face_shape: str  # 얼굴형
    personality_summary: str  # 관상 종합 성격 요약


class JobRecommendation(BaseModel):
    """직업 추천 결과"""
    rank: int
    job_name: str
    job_name_en: str
    description: str
    face_reason: str  # 관상학적 추천 이유
    mbti_reason: str  # MBTI 기반 추천 이유
    match_score: int  # 매칭 점수 (0-100)
    skills: list[str]
    salary_range: str
    outfit_prompt: str  # AI 이미지 생성용 복장 프롬프트
    generated_image_url: Optional[str] = None


class AnalysisResponse(BaseModel):
    """전체 분석 응답"""
    analysis_id: str
    face_features: FaceFeatures
    mbti: str
    mbti_description: str
    recommendations: list[JobRecommendation]
