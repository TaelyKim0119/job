import uuid
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from app.models.schemas import AnalysisRequest, AnalysisResponse
from app.services.face_analyzer import analyze_face
from app.services.job_recommender import recommend_jobs
from app.services.image_generator import generate_job_image

router = APIRouter(prefix="/api/analysis", tags=["analysis"])


@router.post("/analyze", response_model=AnalysisResponse)
async def create_analysis(request: AnalysisRequest):
    """
    메인 분석 API
    1. GPT-4o Vision으로 관상 분석
    2. 관상 + MBTI로 직업 TOP 3 추천
    3. 각 직업별 AI 이미지 생성
    """
    mbti = request.mbti.upper().strip()

    valid_mbtis = [
        "INTJ", "INTP", "ENTJ", "ENTP",
        "INFJ", "INFP", "ENFJ", "ENFP",
        "ISTJ", "ISFJ", "ESTJ", "ESFJ",
        "ISTP", "ISFP", "ESTP", "ESFP",
    ]
    if mbti not in valid_mbtis:
        raise HTTPException(status_code=400, detail=f"유효하지 않은 MBTI: {mbti}")

    # Step 1: 관상 분석
    face_features = await analyze_face(request.photo_url)

    # Step 2: 직업 추천
    mbti_description, recommendations = await recommend_jobs(mbti, face_features)

    # Step 3: AI 이미지 생성 (각 직업별)
    for rec in recommendations:
        try:
            image_url = await generate_job_image(
                request.photo_url, rec.outfit_prompt
            )
            rec.generated_image_url = image_url
        except Exception as e:
            print(f"이미지 생성 실패 ({rec.job_name}): {e}")
            rec.generated_image_url = None

    analysis_id = str(uuid.uuid4())

    return AnalysisResponse(
        analysis_id=analysis_id,
        face_features=face_features,
        mbti=mbti,
        mbti_description=mbti_description,
        recommendations=recommendations,
    )


@router.get("/health")
async def health_check():
    """서버 상태 확인"""
    return {"status": "ok", "service": "직감 API"}
