import json
from openai import OpenAI
from app.core.config import settings
from app.models.schemas import FaceFeatures

FACE_ANALYSIS_PROMPT = """당신은 30년 경력의 전문 관상가입니다. 재미와 엔터테인먼트 목적으로 사용자의 얼굴 사진을 분석합니다.

다음 사진에서 얼굴 특징을 관상학적 관점으로 분석해주세요.

## 분석 항목
1. **이마(forehead)**: 넓이, 높이, 형태 → 지적 능력, 상상력과 연결
2. **눈매(eyes)**: 크기, 형태, 눈꼬리 방향, 쌍꺼풀 유무 → 감수성, 직관력과 연결
3. **코(nose)**: 높이, 형태, 콧망울 크기 → 의지력, 재물운과 연결
4. **입(mouth)**: 크기, 입꼬리 방향, 입술 두께 → 표현력, 리더십과 연결
5. **턱선(jawline)**: 각도, 발달도, 형태 → 추진력, 결단력과 연결
6. **얼굴형(face_shape)**: 긴형/사각형/역삼각형/원형/타원형 중 하나
7. **동물상(animal_type)**: 아래 10가지 중 가장 닮은 동물상 1개를 반드시 선택

## 동물상 판별 기준
- **강아지상**: 동그란 눈, 부드러운 인상, 둥근 얼굴형, 처진 눈꼬리 → 사교적, 충성스러움
- **고양이상**: 날카로운 눈매, 갸름한 얼굴, 올라간 눈꼬리, 도도한 인상 → 독립적, 감각적
- **여우상**: 날렵한 눈매, 뾰족한 턱, 갸름하고 작은 얼굴 → 영리함, 전략적
- **곰상**: 넓은 이마, 큰 코, 넓은 턱, 듬직한 인상 → 포용력, 리더십
- **사슴상**: 큰 눈, 긴 목, 날씬한 체형, 순한 인상 → 순수, 예술적 감각
- **늑대상**: 깊고 날카로운 눈, 강한 턱선, 높은 광대뼈 → 의지력, 추진력
- **토끼상**: 동그란 큰 눈, 작은 입, 앙증맞은 얼굴, 밝은 인상 → 긍정적, 사교적
- **거북이상**: 작은 눈, 넓은 이마, 둥근 턱, 차분한 인상 → 인내심, 꾸준함
- **독수리상**: 매서운 눈매, 높은 콧대, 각진 얼굴, 강렬한 인상 → 통찰력, 비전
- **말상**: 긴 얼굴, 큰 이, 높은 이마, 활발한 인상 → 자유분방, 에너지

각 항목은 2-3문장으로 관상학적 해석을 포함하여 설명합니다.
personality_summary는 동물상 특성을 포함하여 3-4문장으로 작성합니다.

반드시 다음 JSON 형식으로만 응답하세요:
{
  "forehead": "분석 결과",
  "eyes": "분석 결과",
  "nose": "분석 결과",
  "mouth": "분석 결과",
  "jawline": "분석 결과",
  "face_shape": "얼굴형",
  "animal_type": "동물상 (예: 고양이상)",
  "animal_description": "이 동물상으로 판별한 구체적 이유와 성격 특성 (3-4문장)",
  "personality_summary": "동물상을 포함한 종합 성격 요약"
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
