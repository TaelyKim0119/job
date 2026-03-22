import json
from openai import OpenAI
from app.core.config import settings
from app.models.schemas import FaceFeatures

FACE_ANALYSIS_PROMPT = """당신은 30년 경력의 전문 관상가입니다. 재미와 엔터테인먼트 목적으로 사용자의 얼굴 사진을 분석합니다.

다음 사진에서 얼굴 특징을 관상학적 관점으로 분석해주세요.

분석 항목:
1. **이마(forehead)**: 넓이, 높이, 형태 → 지적 능력, 상상력과 연결
2. **눈매(eyes)**: 크기, 형태, 눈꼬리 방향, 쌍꺼풀 유무 → 감수성, 직관력과 연결
3. **코(nose)**: 높이, 형태, 콧망울 크기 → 의지력, 재물운과 연결
4. **입(mouth)**: 크기, 입꼬리 방향, 입술 두께 → 표현력, 리더십과 연결
5. **턱선(jawline)**: 각도, 발달도, 형태 → 추진력, 결단력과 연결
6. **얼굴형(face_shape)**: 긴형/사각형/역삼각형/원형/타원형 중 하나

각 항목은 2-3문장으로 관상학적 해석을 포함하여 설명합니다.
마지막으로 종합적인 성격 요약(personality_summary)을 3-4문장으로 작성합니다.

반드시 다음 JSON 형식으로만 응답하세요:
{
  "forehead": "분석 결과",
  "eyes": "분석 결과",
  "nose": "분석 결과",
  "mouth": "분석 결과",
  "jawline": "분석 결과",
  "face_shape": "얼굴형",
  "personality_summary": "종합 성격 요약"
}

주의: 긍정적이고 격려하는 톤으로 작성하세요. 부정적인 표현은 피하세요.
"""


async def analyze_face(photo_url: str) -> FaceFeatures:
    """GPT-4o Vision으로 관상 분석 수행"""
    client = OpenAI(api_key=settings.openai_api_key)

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "system",
                "content": FACE_ANALYSIS_PROMPT,
            },
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": "이 사진의 얼굴을 관상학적으로 분석해주세요.",
                    },
                    {
                        "type": "image_url",
                        "image_url": {"url": photo_url},
                    },
                ],
            },
        ],
        max_tokens=1500,
        temperature=0.7,
        response_format={"type": "json_object"},
    )

    result = json.loads(response.choices[0].message.content)
    return FaceFeatures(**result)
