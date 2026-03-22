from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.analysis import router as analysis_router
from app.core.config import settings

app = FastAPI(
    title="직감(職感) API",
    description="관상 × MBTI 직업 추천 서비스",
    version="0.1.0",
)

# CORS 설정 (Flutter 앱에서 접근 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 등록
app.include_router(analysis_router)


@app.get("/")
async def root():
    return {
        "app": "직감(職感)",
        "tagline": "Read Your Face. Find Your Path.",
        "version": "0.1.0",
        "docs": "/docs",
    }
