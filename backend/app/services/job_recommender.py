import json
from openai import OpenAI
from app.core.config import settings
from app.models.schemas import FaceFeatures, JobRecommendation

JOB_RECOMMENDATION_PROMPT = """당신은 관상학 전문가이자 MBTI 직업 상담 전문가입니다.
재미와 엔터테인먼트 목적으로 사용자에게 어울리는 직업 TOP 3를 추천합니다.

## 규칙
1. **아래 한국 초중고 희망직업 TOP 20을 참고하여 추천하세요** (이 직업들 중심으로, 관상과 MBTI에 맞는 것을 골라 추천):
   교사/교수, 의사, 간호사, 운동선수, 경찰관/수사관, 법률전문가, 군인,
   공무원, 회사원, 프로그래머/개발자, 요리사/조리사, 제과제빵원, CEO/경영자,
   약사, 배우/모델, 가수/뮤지컬배우, 뷰티디자이너, 시각디자이너, 작가,
   만화가/웹툰작가, 프로게이머, 수의사, 크리에이터/유튜버, 감독/PD,
   과학자/연구원, 건축가, 광고마케팅전문가, 동물사육사, 보건의료기술직
2. 위 직업 외에도 관상과 MBTI에 특별히 잘 맞는 **독특한 직업**을 섞어서 추천해도 됩니다:
   - 조향사, 소믈리에, 푸드스타일리스트, 수중촬영감독
   - 범죄 프로파일러, 문화재 복원사, 게임 사운드 디자이너
   - 드론 조종사, 타투이스트, 식물원 큐레이터
   - 위기협상가, 향수 조향사, 가죽공예 장인
   - 컬러리스트, 미래학자, 수면 컨설턴트
3. 각 직업에 대해 **관상학적 이유**와 **MBTI 연계 이유**를 구체적으로 설명하세요.
4. **outfit_prompt**는 Stable Diffusion 이미지 생성용 영어 프롬프트입니다. 해당 직업의 전형적인 복장과 작업 환경을 상세히 묘사하세요.
5. 매칭 점수는 75-98 사이로 다양하게 분배하세요.

## 사용자 정보
- MBTI: {mbti}
- 관상 분석 결과:
  - 이마: {forehead}
  - 눈매: {eyes}
  - 코: {nose}
  - 입: {mouth}
  - 턱선: {jawline}
  - 얼굴형: {face_shape}
  - 동물상: {animal_type}
  - 동물상 설명: {animal_description}
  - 성격 요약: {personality_summary}

## 응답 형식 (JSON)
{{
  "mbti_description": "해당 MBTI 유형의 핵심 성격 설명 (2-3문장)",
  "recommendations": [
    {{
      "rank": 1,
      "job_name": "직업명 (한국어)",
      "job_name_en": "Job Name (English)",
      "description": "이 직업이 하는 일 설명 (2-3문장)",
      "face_reason": "관상학적 추천 이유 (3-4문장, 구체적 얼굴 특징 언급)",
      "mbti_reason": "MBTI 기반 추천 이유 (2-3문장)",
      "match_score": 92,
      "skills": ["필요 스킬1", "필요 스킬2", "필요 스킬3"],
      "salary_range": "연봉 범위 (예: 3,000~6,000만원)",
      "outfit_prompt": "professional [job] wearing [specific outfit details], [work environment], professional lighting, portrait photo, high quality, 4K"
    }}
  ]
}}
"""


async def recommend_jobs(
    mbti: str, face_features: FaceFeatures
) -> tuple[str, list[JobRecommendation]]:
    """관상 + MBTI 기반 직업 TOP 3 추천"""
    client = OpenAI(api_key=settings.openai_api_key)

    prompt = JOB_RECOMMENDATION_PROMPT.format(
        mbti=mbti,
        forehead=face_features.forehead,
        eyes=face_features.eyes,
        nose=face_features.nose,
        mouth=face_features.mouth,
        jawline=face_features.jawline,
        face_shape=face_features.face_shape,
        animal_type=face_features.animal_type,
        animal_description=face_features.animal_description,
        personality_summary=face_features.personality_summary,
    )

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": prompt},
            {
                "role": "user",
                "content": "위 관상 분석과 MBTI를 기반으로 어울리는 독특한 직업 TOP 3를 추천해주세요.",
            },
        ],
        max_tokens=3000,
        temperature=0.85,
        response_format={"type": "json_object"},
    )

    result = json.loads(response.choices[0].message.content)

    mbti_description = result["mbti_description"]
    recommendations = [JobRecommendation(**job) for job in result["recommendations"]]

    return mbti_description, recommendations
