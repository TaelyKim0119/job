const VALID_MBTIS = new Set([
  'INTJ','INTP','ENTJ','ENTP','INFJ','INFP','ENFJ','ENFP',
  'ISTJ','ISFJ','ESTJ','ESFJ','ISTP','ISFP','ESTP','ESFP',
])

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

const FACE_ANALYSIS_PROMPT = `당신은 30년 경력의 대한민국 최고 관상학 대가(大家)입니다. 동양 관상학의 정통 이론인 마의상법(麻衣相法), 신상전편(神相全篇)에 정통합니다.

재미와 엔터테인먼트 목적으로 사용자의 얼굴 사진을 분석합니다.

다음 사진에서 얼굴 특징을 전문 관상학 용어를 사용하여 분석해주세요.

분석 항목:
1. 이마(forehead) - 천정(天庭) 영역, 관록궁 분석 (3-4문장)
2. 눈매(eyes) - 감찰관(監察官), 안신(眼神) 분석 (3-4문장)
3. 코(nose) - 심판관(審辨官), 재백궁 분석 (3-4문장)
4. 입(mouth) - 출납관(出納官), 식록 분석 (3-4문장)
5. 턱선(jawline) - 지각(地閣), 만년운 분석 (3-4문장)
6. 얼굴형(face_shape) - 긴형/사각형/역삼각형/원형/타원형 중 하나 (오행 분류 포함)
7. 동물상(animal_type) - 강아지/고양이/여우/곰/사슴/늑대/토끼/거북이/독수리/말상 중 1개
8. 동물상 설명(animal_description) - 판별 이유와 성격 특성 (4-5문장)
9. 성격 종합(personality_summary) - 삼정·오관·동물상 종합 감정문 (5-6문장)

긍정적이고 격려하는 톤으로, 전문 관상학 대가의 품격을 유지하세요.
반드시 JSON으로만 응답하세요.`

const JOB_PROMPT_TEMPLATE = `당신은 관상학 전문가이자 MBTI 직업 상담 전문가입니다.
재미와 엔터테인먼트 목적으로 사용자에게 어울리는 직업 TOP 3를 추천합니다.

규칙:
1. 한국 희망직업 TOP 20 참고: 교사, 의사, 간호사, 운동선수, 경찰관, 법률전문가, 프로그래머, 요리사, CEO, 배우, 가수, 디자이너, 작가, 과학자, 건축가 등
2. 독특한 직업도 섞어서 추천 가능: 조향사, 소믈리에, 범죄 프로파일러, 문화재 복원사, 게임 사운드 디자이너 등
3. 관상학적 이유와 MBTI 연계 이유를 구체적으로
4. outfit_prompt는 이미지 생성용 영어 프롬프트
5. 매칭 점수는 75-98 사이

사용자 정보:
- MBTI: {mbti}
- 이마: {forehead}
- 눈매: {eyes}
- 코: {nose}
- 입: {mouth}
- 턱선: {jawline}
- 얼굴형: {face_shape}
- 동물상: {animal_type}
- 동물상 설명: {animal_description}
- 성격 요약: {personality_summary}

JSON 응답:
{
  "mbti_description": "MBTI 유형 설명 (2-3문장)",
  "recommendations": [
    {
      "rank": 1,
      "job_name": "직업명 (한국어)",
      "job_name_en": "Job Name",
      "description": "직업 설명 (2-3문장)",
      "face_reason": "관상학적 이유 (3-4문장)",
      "mbti_reason": "MBTI 기반 이유 (2-3문장)",
      "match_score": 92,
      "skills": ["스킬1", "스킬2", "스킬3"],
      "salary_range": "연봉 범위",
      "outfit_prompt": "professional [job] wearing [outfit], [environment], portrait photo, high quality"
    }
  ]
}`

async function analyzeFace(photoUrl, apiKey) {
  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${apiKey}` },
    body: JSON.stringify({
      model: 'gpt-4o',
      messages: [
        { role: 'system', content: FACE_ANALYSIS_PROMPT },
        { role: 'user', content: [
          { type: 'text', text: '이 사진의 얼굴을 관상학적으로 분석해주세요.' },
          { type: 'image_url', image_url: { url: photoUrl } },
        ]},
      ],
      max_tokens: 1500,
      temperature: 0.7,
      response_format: { type: 'json_object' },
    }),
  })
  if (!res.ok) throw new Error(`OpenAI face analysis failed: ${res.status}`)
  const data = await res.json()
  return JSON.parse(data.choices[0].message.content)
}

async function recommendJobs(mbti, face, apiKey) {
  const prompt = JOB_PROMPT_TEMPLATE
    .replace('{mbti}', mbti)
    .replace('{forehead}', face.forehead)
    .replace('{eyes}', face.eyes)
    .replace('{nose}', face.nose)
    .replace('{mouth}', face.mouth)
    .replace('{jawline}', face.jawline)
    .replace('{face_shape}', face.face_shape)
    .replace('{animal_type}', face.animal_type)
    .replace('{animal_description}', face.animal_description)
    .replace('{personality_summary}', face.personality_summary)

  const res = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${apiKey}` },
    body: JSON.stringify({
      model: 'gpt-4o',
      messages: [
        { role: 'system', content: prompt },
        { role: 'user', content: '위 관상 분석과 MBTI를 기반으로 어울리는 독특한 직업 TOP 3를 추천해주세요.' },
      ],
      max_tokens: 3000,
      temperature: 0.85,
      response_format: { type: 'json_object' },
    }),
  })
  if (!res.ok) throw new Error(`OpenAI job recommendation failed: ${res.status}`)
  const data = await res.json()
  return JSON.parse(data.choices[0].message.content)
}

async function generateJobImage(photoUrl, outfitPrompt, geminiKey) {
  // Extract base64 from data URL
  const [header, b64Data] = photoUrl.split(',')
  const mimeType = header.split(':')[1].split(';')[0]

  const prompt = `이 사진 속 인물의 얼굴, 피부톤, 체형을 최대한 동일하게 유지하면서 ${outfitPrompt} 복장을 입힌 전문적인 직업 초상 사진을 생성해주세요. 배경은 해당 직업의 실제 근무 환경으로 자연스럽게 설정하세요. 사실적인 사진 스타일, 따뜻한 조명, 고품질. 텍스트나 워터마크 없이 생성하세요.`

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=${geminiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          role: 'user',
          parts: [
            { inlineData: { mimeType, data: b64Data } },
            { text: prompt },
          ],
        }],
        generationConfig: {
          responseModalities: ['TEXT', 'IMAGE'],
        },
      }),
    }
  )

  if (!res.ok) throw new Error(`Gemini image generation failed: ${res.status}`)
  const data = await res.json()

  // Find image in response
  const parts = data.candidates?.[0]?.content?.parts || []
  for (const part of parts) {
    if (part.inlineData) {
      const imgMime = part.inlineData.mimeType || 'image/png'
      return `data:${imgMime};base64,${part.inlineData.data}`
    }
  }
  throw new Error('No image in Gemini response')
}

export async function onRequestPost(context) {
  try {
    const { OPENAI_API_KEY, GEMINI_API_KEY } = context.env

    if (!OPENAI_API_KEY || !GEMINI_API_KEY) {
      return new Response(JSON.stringify({ detail: 'API keys not configured' }), {
        status: 500, headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
      })
    }

    const body = await context.request.json()
    const { photo, mbti } = body

    if (!photo || !mbti) {
      return new Response(JSON.stringify({ detail: 'photo and mbti are required' }), {
        status: 400, headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
      })
    }

    const mbtiUpper = mbti.toUpperCase().trim()
    if (!VALID_MBTIS.has(mbtiUpper)) {
      return new Response(JSON.stringify({ detail: `유효하지 않은 MBTI: ${mbti}` }), {
        status: 400, headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
      })
    }

    // Step 1: Face analysis
    const faceFeatures = await analyzeFace(photo, OPENAI_API_KEY)

    // Step 2: Job recommendations
    const jobResult = await recommendJobs(mbtiUpper, faceFeatures, OPENAI_API_KEY)

    // Step 3: Image generation (parallel)
    const imagePromises = (jobResult.recommendations || []).map(async (rec) => {
      try {
        if (rec.outfit_prompt) {
          const imageUrl = await generateJobImage(photo, rec.outfit_prompt, GEMINI_API_KEY)
          rec.generated_image_url = imageUrl
        }
      } catch (e) {
        console.error(`Image generation failed for ${rec.job_name}:`, e.message)
        rec.generated_image_url = null
      }
    })
    await Promise.allSettled(imagePromises)

    const result = {
      analysis_id: crypto.randomUUID(),
      face_features: faceFeatures,
      mbti: mbtiUpper,
      mbti_description: jobResult.mbti_description,
      recommendations: jobResult.recommendations,
    }

    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
    })

  } catch (error) {
    console.error('Analysis error:', error)
    return new Response(JSON.stringify({ detail: `분석 중 서버 오류: ${error.message}` }), {
      status: 500, headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
    })
  }
}

export async function onRequestOptions() {
  return new Response(null, { headers: CORS_HEADERS })
}
