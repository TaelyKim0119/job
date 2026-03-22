import replicate
from app.core.config import settings


async def generate_job_image(
    user_photo_url: str, outfit_prompt: str
) -> str:
    """사용자 얼굴 + 직업 복장 AI 이미지 생성 (Replicate API)

    IP-Adapter FaceID + SDXL을 사용하여
    유저의 얼굴을 유지하면서 직업 복장을 입힌 이미지를 생성합니다.
    """
    client = replicate.Client(api_token=settings.replicate_api_token)

    # IP-Adapter FaceID를 활용한 이미지 생성
    full_prompt = (
        f"A professional portrait photo of a person as a {outfit_prompt}, "
        f"natural expression, studio lighting, high resolution, "
        f"detailed face, photorealistic, 4K quality"
    )

    output = client.run(
        "lucataco/ip-adapter-faceid:baa587cd1a7477e4ba5e5fe88e10b34dfe452cb208e7e1a601a0e86aec539753",
        input={
            "image": user_photo_url,
            "prompt": full_prompt,
            "negative_prompt": (
                "blurry, low quality, distorted face, "
                "cartoon, anime, illustration, painting, "
                "ugly, deformed, extra limbs"
            ),
            "num_inference_steps": 30,
            "guidance_scale": 7.5,
            "ip_adapter_scale": 0.65,
            "width": 768,
            "height": 1024,
        },
    )

    # Replicate returns a list of URLs
    if isinstance(output, list) and len(output) > 0:
        return str(output[0])
    return str(output)
