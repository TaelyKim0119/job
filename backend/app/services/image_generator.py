from openai import OpenAI
from app.core.config import settings


async def generate_job_image(
    user_photo_url: str, outfit_prompt: str
) -> str:
    """직업 복장 AI 이미지 생성 (DALL-E 3)

    MVP: DALL-E 3로 직업 복장 이미지를 생성합니다.
    얼굴 동일성 유지는 불가하지만, 직업의 분위기를 전달합니다.
    추후 Replicate IP-Adapter FaceID로 업그레이드 가능.
    """
    client = OpenAI(api_key=settings.openai_api_key)

    full_prompt = (
        f"A professional portrait photo of a young Korean person working as a {outfit_prompt}. "
        f"The person looks confident and natural in their work environment. "
        f"Photorealistic style, warm lighting, shallow depth of field, "
        f"high quality portrait photography, 4K. "
        f"No text, no watermark."
    )

    response = client.images.generate(
        model="dall-e-3",
        prompt=full_prompt,
        size="1024x1792",  # Portrait orientation
        quality="standard",
        n=1,
    )

    return response.data[0].url
