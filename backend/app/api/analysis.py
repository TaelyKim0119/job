import uuid
import base64
import asyncio
import traceback
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from fastapi.responses import JSONResponse
from app.models.schemas import AnalysisRequest, AnalysisResponse
from app.services.face_analyzer import analyze_face
from app.services.job_recommender import recommend_jobs
from app.services.image_generator import generate_job_image

router = APIRouter(prefix="/api/analysis", tags=["analysis"])

VALID_MBTIS = [
    "INTJ", "INTP", "ENTJ", "ENTP",
    "INFJ", "INFP", "ENFJ", "ENFP",
    "ISTJ", "ISFJ", "ESTJ", "ESFJ",
    "ISTP", "ISFP", "ESTP", "ESFP",
]


@router.post("/upload-and-analyze")
async def upload_and_analyze(
    photo: UploadFile = File(...),
    mbti: str = Form(...),
):
    """사진 파일 업로드 + 분석 API"""
    try:
        mbti = mbti.upper().strip()
        if mbti not in VALID_MBTIS:
            raise HTTPException(status_code=400, detail=f"유효하지 않은 MBTI: {mbti}")

        print(f"[분석 시작] MBTI: {mbti}, 파일: {photo.filename}, 타입: {photo.content_type}")

        # Read and encode photo
        photo_bytes = await photo.read()
        print(f"[사진] 크기: {len(photo_bytes)} bytes")

        if len(photo_bytes) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="사진 크기는 10MB 이하여야 합니다")

        content_type = photo.content_type or "image/jpeg"
        photo_b64 = base64.b64encode(photo_bytes).decode("utf-8")
        photo_data_url = f"data:{content_type};base64,{photo_b64}"

        # Step 1: 관상 분석
        print("[Step 1] 관상 분석 시작...")
        face_features = await analyze_face(photo_data_url)
        print(f"[Step 1] 관상 분석 완료: {face_features.face_shape}")

        # Step 2: 직업 추천
        print("[Step 2] 직업 추천 시작...")
        mbti_description, recommendations = await recommend_jobs(mbti, face_features)
        print(f"[Step 2] 직업 추천 완료: {[r.job_name for r in recommendations]}")

        # Step 3: AI 이미지 생성 (병렬 처리)
        async def generate_for_rec(rec):
            try:
                print(f"[Step 3] 이미지 생성: {rec.job_name}...")
                image_url = await generate_job_image(
                    photo_data_url, rec.outfit_prompt
                )
                rec.generated_image_url = image_url
                print(f"[Step 3] 이미지 완료: {rec.job_name}")
            except Exception as e:
                print(f"[Step 3] 이미지 생성 실패 ({rec.job_name}): {e}")
                rec.generated_image_url = None

        print("[Step 3] 이미지 3개 병렬 생성 시작...")
        await asyncio.gather(*[generate_for_rec(rec) for rec in recommendations])

        analysis_id = str(uuid.uuid4())
        print(f"[완료] 분석 ID: {analysis_id}")

        result = AnalysisResponse(
            analysis_id=analysis_id,
            face_features=face_features,
            mbti=mbti,
            mbti_description=mbti_description,
            recommendations=recommendations,
        )
        return result

    except HTTPException:
        raise
    except Exception as e:
        print(f"[에러] {traceback.format_exc()}")
        return JSONResponse(
            status_code=500,
            content={"detail": f"분석 중 서버 오류: {str(e)}"},
        )


@router.post("/test-upload")
async def test_upload(
    photo: UploadFile = File(...),
    mbti: str = Form(...),
):
    """업로드 테스트 (API 호출 없이 연결만 확인)"""
    photo_bytes = await photo.read()
    return {
        "status": "ok",
        "mbti": mbti,
        "filename": photo.filename,
        "content_type": photo.content_type,
        "size_bytes": len(photo_bytes),
    }


@router.get("/health")
async def health_check():
    """서버 상태 확인"""
    return {"status": "ok", "service": "직감 API"}
