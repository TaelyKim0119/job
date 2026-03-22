import uuid
import base64
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from app.models.schemas import AnalysisRequest, AnalysisResponse
from app.services.face_analyzer import analyze_face
from app.services.job_recommender import recommend_jobs
from app.services.image_generator import generate_job_image

router = APIRouter(prefix="/api/analysis", tags=["analysis"])


@router.post("/upload-and-analyze", response_model=AnalysisResponse)
async def upload_and_analyze(
    photo: UploadFile = File(...),
    mbti: str = Form(...),
):
    """
    사진 파일 업로드 + 분석 API
    1. 사진을 base64로 변환하여 GPT-4o Vision에 전달
    2. 관상 + MBTI로 직업 TOP 3 추천
    3. 각 직업별 AI 이미지 생성
    """
    mbti = mbti.upper().strip()

    valid_mbtis = [
        "INTJ", "INTP", "ENTJ", "ENTP",
        "INFJ", "INFP", "ENFJ", "ENFP",
        "ISTJ", "ISFJ", "ESTJ", "ESFJ",
        "ISTP", "ISFP", "ESTP", "ESFP",
    ]
    if mbti not in valid_mbtis:
        raise HTTPException(status_code=400, detail=f"유효하지 않은 MBTI: {mbti}")

    # Read and encode photo
    photo_bytes = await photo.read()
    if len(photo_bytes) > 10 * 1024 * 1024:  # 10MB limit
        raise HTTPException(status_code=400, detail="사진 크기는 10MB 이하여야 합니다")

    content_type = photo.content_type or "image/jpeg"
    photo_b64 = base64.b64encode(photo_bytes).decode("utf-8")
    photo_data_url = f"data:{content_type};base64,{photo_b64}"

    # Step 1: 관상 분석
    face_features = await analyze_face(photo_data_url)

    # Step 2: 직업 추천
    mbti_description, recommendations = await recommend_jobs(mbti, face_features)

    # Step 3: AI 이미지 생성 (각 직업별)
    for rec in recommendations:
        try:
            image_url = await generate_job_image(
                photo_data_url, rec.outfit_prompt
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


@router.post("/analyze", response_model=AnalysisResponse)
async def create_analysis(request: AnalysisRequest):
    """
    URL 기반 분석 API (테스트/디버그용)
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

    face_features = await analyze_face(request.photo_url)
    mbti_description, recommendations = await recommend_jobs(mbti, face_features)

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
