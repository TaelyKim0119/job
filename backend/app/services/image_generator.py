import base64
from google import genai
from google.genai import types
from app.core.config import settings


async def generate_job_image(
    user_photo_url: str, outfit_prompt: str
) -> str:
    """Gemini 이미지 생성: 사용자 사진 + 직업 복장 합성

    사용자의 실제 사진을 입력으로 받아,
    해당 직업의 복장을 입힌 이미지를 생성합니다.
    """
    client = genai.Client(api_key=settings.gemini_api_key)

    # data URL에서 base64 추출
    if user_photo_url.startswith("data:"):
        header, b64_data = user_photo_url.split(",", 1)
        mime_type = header.split(":")[1].split(";")[0]
        image_bytes = base64.b64decode(b64_data)
    else:
        raise ValueError("data URL 형식의 이미지만 지원합니다")

    prompt = (
        f"이 사진 속 인물의 얼굴, 피부톤, 체형을 최대한 동일하게 유지하면서 "
        f"{outfit_prompt} 복장을 입힌 전문적인 직업 초상 사진을 생성해주세요. "
        f"배경은 해당 직업의 실제 근무 환경으로 자연스럽게 설정하세요. "
        f"사실적인 사진 스타일, 따뜻한 조명, 고품질. "
        f"텍스트나 워터마크 없이 생성하세요."
    )

    print(f"[Gemini] 이미지 생성 시작: {outfit_prompt}")

    response = client.models.generate_content(
        model="gemini-2.5-flash-image",
        contents=[
            types.Content(
                role="user",
                parts=[
                    types.Part.from_bytes(data=image_bytes, mime_type=mime_type),
                    types.Part.from_text(text=prompt),
                ],
            )
        ],
        config=types.GenerateContentConfig(
            response_modalities=["TEXT", "IMAGE"],
        ),
    )

    # 응답에서 이미지 추출
    for part in response.candidates[0].content.parts:
        if part.inline_data is not None:
            img_b64 = base64.b64encode(part.inline_data.data).decode("utf-8")
            img_mime = part.inline_data.mime_type or "image/png"
            print(f"[Gemini] 이미지 생성 완료 ({len(img_b64)} chars)")
            return f"data:{img_mime};base64,{img_b64}"

    raise Exception("Gemini 이미지 생성 결과를 찾을 수 없습니다")
