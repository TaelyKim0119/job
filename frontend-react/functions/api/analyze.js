const VALID_MBTIS = new Set([
  'INTJ','INTP','ENTJ','ENTP','INFJ','INFP','ENFJ','ENFP',
  'ISTJ','ISFJ','ESTJ','ESFJ','ISTP','ISFP','ESTP','ESFP',
])

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

const GEMINI_TEXT_MODEL = 'gemini-2.0-flash'
const GEMINI_IMAGE_MODEL = 'gemini-2.5-flash-image'

// ── 기본 관상 분석 프롬프트 ──
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
반드시 JSON으로만 응답하세요. 마크다운 코드블록 없이 순수 JSON만 출력하세요.`

// ── 고급 관상 분석 프롬프트 ──
const PREMIUM_FACE_ANALYSIS_PROMPT = `당신은 30년 경력의 대한민국 최고 관상학 대가(大家)입니다.
마의상법(麻衣相法), 신상전편(神相全篇), 유장상법(柳莊相法)에 정통하며, 삼정오관(三停五官) 이론의 최고 권위자입니다.

재미와 엔터테인먼트 목적으로 사용자의 얼굴 사진을 심층 분석합니다.

■ 심층 분석 항목:

[오관(五官) 분석]
1. 이마(forehead) - 천정(天庭)·관록궁·사공(司空). 넓이, 기울기, 이마뼈 돌출 여부, 주름 유무 (4-5문장)
2. 눈썹(eyebrows) - 보수관(保壽官)·형제궁. 눈썹 굵기, 길이, 간격, 모양(일자/아치/초승달), 눈썹뼈 돌출 (3-4문장)
3. 눈매(eyes) - 감찰관(監察官)·안신(眼神). 눈 크기, 쌍꺼풀, 눈꼬리 방향, 흑백 비율, 눈빛의 힘 (4-5문장)
4. 코(nose) - 심판관(審辨官)·재백궁. 콧대 높이와 직선도, 코끝(준두) 형태, 콧볼 크기, 콧구멍 노출 (4-5문장)
5. 입(mouth) - 출납관(出納官)·식록. 입술 두께, 색상, 입꼬리 방향, 인중 길이와 깊이 (4-5문장)
6. 귀(ears) - 채청관(採聽官)·수명·유년환경. 귀 크기, 귓불 두께, 귀의 위치(눈 높이 기준), 귀 색상 (3-4문장)

[삼정(三停) 비율 분석]
7. 삼정비율(samjeong_ratio) - 상정(이마선~눈썹):중정(눈썹~코끝):하정(코끝~턱끝) 비율. 각 부위가 긴지/짧은지, 어느 시기의 운이 강한지 (4-5문장)

[오행(五行) 체질]
8. 얼굴형(face_shape) - 긴형/사각형/역삼각형/원형/타원형 중 하나
9. 오행체질(element_type) - 목(木)·화(火)·토(土)·금(金)·수(水) 중 하나. 얼굴형+골격+피부+체형 종합 판단 (3-4문장)

[기색(氣色) 분석]
10. 기색(complexion) - 피부톤(밝은/어두운/붉은/누런), 혈색, 윤기, 피부결. 현재 기운의 흐름 해석 (3-4문장)

[동물상]
11. 동물상(animal_type) - 강아지/고양이/여우/곰/사슴/늑대/토끼/거북이/독수리/말상 중 1개
12. 동물상 설명(animal_description) - 판별 이유와 성격 특성 (4-5문장)

[종합 감정]
13. 성격 종합(personality_summary) - 삼정·오관·오행·기색·동물상을 종합한 대가의 감정문. 이 사람의 타고난 기질, 강점, 잠재력을 격조 있게 서술 (6-8문장)

긍정적이고 격려하는 톤으로, 전문 관상학 대가의 품격을 유지하세요.
반드시 JSON으로만 응답하세요. 마크다운 코드블록 없이 순수 JSON만 출력하세요.`

const JOB_PROMPT_TEMPLATE = `당신은 관상학 전문가이자 MBTI 직업 상담 전문가입니다.
재미와 엔터테인먼트 목적으로 사용자에게 어울리는 직업 TOP 3를 추천합니다.

규칙:
1. 3개 직업은 반드시 서로 다른 분야여야 합니다. 같은 업종끼리 겹치지 마세요.
2. 가능한 직업 풀 (예시이며 이외 직업도 자유롭게 추천):
   - 전문직: 의사, 변호사, 건축가, 수의사, 약사, 심리상담사, 통역사
   - 예술/창작: 영화감독, 사진작가, 웹툰작가, 패션디자이너, 무대연출가, 일러스트레이터
   - 기술/IT: AI 연구원, 게임개발자, 로봇공학자, 데이터사이언티스트, 사이버보안전문가
   - 자연/과학: 해양생물학자, 천문학자, 식물학자, 기상캐스터, 환경운동가
   - 독특한 직업: 조향사, 소믈리에, 범죄프로파일러, 문화재복원사, 게임사운드디자이너, 드론파일럿, 우주비행사, 미식평론가, 보석감정사, 폴리아티스트
   - 비즈니스: CEO, 벤처투자자, 브랜드매니저, 외교관, 국제기구활동가
   - 공공/봉사: 소방관, 경찰관, 교사, 사회복지사, 국립공원레인저
   - 요식/라이프: 파티시에, 바리스타, 플로리스트, 요가강사, 스포츠에이전트
3. 매번 다른 조합으로 추천하세요. 뻔한 조합(교사+의사+프로그래머 등) 금지.
4. 관상학적 이유와 MBTI 연계 이유를 구체적으로
5. outfit_prompt는 이미지 생성용 영어 프롬프트
6. 매칭 점수는 75-98 사이

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

반드시 아래 JSON 형식으로만 응답하세요. 마크다운 코드블록 없이 순수 JSON만 출력하세요.
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
      "outfit_prompt": "professional [job] wearing [outfit], [environment], portrait photo, high quality"
    }
  ]
}`

// ── 고급 직업 매칭 프롬프트 ──
const PREMIUM_JOB_PROMPT_TEMPLATE = `당신은 관상학 대가이자 MBTI 직업 상담 전문가입니다.
삼정(三停), 오관(五官), 오행(五行), 기색(氣色) 심층 분석 결과와 MBTI를 교차하여 천직(天職)을 찾습니다.

■ 오행-직업 적성 매핑 (참고용, 반드시 따를 필요는 없음):
- 목형(木): 학자, 교수, 연구원, 작가, 교육자, 법관 — 사고력·논리력 우수
- 화형(火): 예술가, 마케터, 방송인, 디자이너, 연출가 — 표현력·열정 강함
- 토형(土): 경영자, 부동산, 농업전문가, 중재자, 정치인 — 안정감·신뢰 중심
- 금형(金): 군인, 법조인, 금융인, 외과의, 엔지니어 — 결단력·정밀함
- 수형(水): 외교관, IT전문가, 탐정, 심리학자, 전략가 — 적응력·지혜

■ 규칙:
1. 3개 직업은 반드시 서로 다른 분야에서. 같은 업종 겹침 금지.
2. 오행 체질과 삼정 비율을 직업 적성 판단에 적극 활용하세요.
3. 기색(氣色)에서 읽히는 현재 에너지 흐름도 직업 추천에 반영하세요.
4. 가능한 직업 풀 (예시이며 이외 직업도 자유롭게 추천):
   - 전문직: 의사, 변호사, 건축가, 수의사, 약사, 심리상담사, 통역사
   - 예술/창작: 영화감독, 사진작가, 웹툰작가, 패션디자이너, 무대연출가, 일러스트레이터
   - 기술/IT: AI 연구원, 게임개발자, 로봇공학자, 데이터사이언티스트, 사이버보안전문가
   - 자연/과학: 해양생물학자, 천문학자, 식물학자, 기상캐스터, 환경운동가
   - 독특한 직업: 조향사, 소믈리에, 범죄프로파일러, 문화재복원사, 드론파일럿, 우주비행사, 보석감정사
   - 비즈니스: CEO, 벤처투자자, 브랜드매니저, 외교관, 국제기구활동가
   - 공공/봉사: 소방관, 경찰관, 교사, 사회복지사, 국립공원레인저
   - 요식/라이프: 파티시에, 바리스타, 플로리스트, 요가강사, 스포츠에이전트
5. 뻔한 조합 금지. 매번 다른 조합으로 추천.
6. face_reason에 오행·삼정·기색 근거를 구체적으로 포함
7. outfit_prompt는 이미지 생성용 영어 프롬프트
8. 매칭 점수는 75-98 사이

사용자 정보:
- MBTI: {mbti}
- 이마: {forehead}
- 눈썹: {eyebrows}
- 눈매: {eyes}
- 코: {nose}
- 입: {mouth}
- 귀: {ears}
- 턱선: {jawline}
- 삼정비율: {samjeong_ratio}
- 얼굴형: {face_shape}
- 오행체질: {element_type}
- 기색: {complexion}
- 동물상: {animal_type}
- 동물상 설명: {animal_description}
- 성격 요약: {personality_summary}

반드시 아래 JSON 형식으로만 응답하세요. 마크다운 코드블록 없이 순수 JSON만 출력하세요.
{
  "mbti_description": "MBTI 유형 설명 (2-3문장)",
  "element_job_insight": "오행 체질과 직업 적성 연결 설명 (3-4문장)",
  "recommendations": [
    {
      "rank": 1,
      "job_name": "직업명 (한국어)",
      "job_name_en": "Job Name",
      "description": "직업 설명 (2-3문장)",
      "face_reason": "관상학적 이유 - 오행·삼정·기색 포함 (4-6문장)",
      "mbti_reason": "MBTI 기반 이유 (2-3문장)",
      "match_score": 92,
      "skills": ["스킬1", "스킬2", "스킬3"],
      "outfit_prompt": "professional [job] wearing [outfit], [environment], portrait photo, high quality"
    }
  ]
}`

// JSON 파싱 헬퍼: 마크다운 코드블록 제거
function parseJSON(text) {
  const cleaned = text.replace(/```json\s*/gi, '').replace(/```\s*/g, '').trim()
  return JSON.parse(cleaned)
}

// Gemini 텍스트+이미지 분석 (관상 분석)
async function analyzeFace(photoUrl, geminiKey, mode = 'basic') {
  const [header, b64Data] = photoUrl.split(',')
  const mimeType = header.split(':')[1].split(';')[0]
  const isPremium = mode === 'premium'

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_TEXT_MODEL}:generateContent?key=${geminiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          role: 'user',
          parts: [
            { text: isPremium ? PREMIUM_FACE_ANALYSIS_PROMPT : FACE_ANALYSIS_PROMPT },
            { inlineData: { mimeType, data: b64Data } },
            { text: isPremium
              ? '이 사진의 얼굴을 삼정·오관·오행·기색까지 심층 관상학적으로 분석해주세요. JSON으로만 응답하세요.'
              : '이 사진의 얼굴을 관상학적으로 분석해주세요. JSON으로만 응답하세요.' },
          ],
        }],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: isPremium ? 4000 : 2000,
          responseMimeType: 'application/json',
        },
      }),
    }
  )

  if (!res.ok) {
    const err = await res.text()
    throw new Error(`Gemini face analysis failed: ${res.status} - ${err.slice(0, 200)}`)
  }
  const data = await res.json()
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text
  if (!text) throw new Error('Gemini returned no text for face analysis')
  return parseJSON(text)
}

// Gemini 텍스트 생성 (직업 추천)
async function recommendJobs(mbti, face, geminiKey, mode = 'basic') {
  const isPremium = mode === 'premium'

  let prompt
  if (isPremium) {
    prompt = PREMIUM_JOB_PROMPT_TEMPLATE
      .replace('{mbti}', mbti)
      .replace('{forehead}', face.forehead || '')
      .replace('{eyebrows}', face.eyebrows || '')
      .replace('{eyes}', face.eyes || '')
      .replace('{nose}', face.nose || '')
      .replace('{mouth}', face.mouth || '')
      .replace('{ears}', face.ears || '')
      .replace('{jawline}', face.jawline || '')
      .replace('{samjeong_ratio}', face.samjeong_ratio || '')
      .replace('{face_shape}', face.face_shape || '')
      .replace('{element_type}', face.element_type || '')
      .replace('{complexion}', face.complexion || '')
      .replace('{animal_type}', face.animal_type || '')
      .replace('{animal_description}', face.animal_description || '')
      .replace('{personality_summary}', face.personality_summary || '')
  } else {
    prompt = JOB_PROMPT_TEMPLATE
      .replace('{mbti}', mbti)
      .replace('{forehead}', face.forehead || '')
      .replace('{eyes}', face.eyes || '')
      .replace('{nose}', face.nose || '')
      .replace('{mouth}', face.mouth || '')
      .replace('{jawline}', face.jawline || '')
      .replace('{face_shape}', face.face_shape || '')
      .replace('{animal_type}', face.animal_type || '')
      .replace('{animal_description}', face.animal_description || '')
      .replace('{personality_summary}', face.personality_summary || '')
  }

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_TEXT_MODEL}:generateContent?key=${geminiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{
          role: 'user',
          parts: [
            { text: prompt },
            { text: isPremium
              ? '위 심층 관상 분석(삼정·오행·기색)과 MBTI를 교차하여 천직 TOP 3를 추천해주세요. JSON으로만 응답하세요.'
              : '위 관상 분석과 MBTI를 기반으로 어울리는 독특한 직업 TOP 3를 추천해주세요. JSON으로만 응답하세요.' },
          ],
        }],
        generationConfig: {
          temperature: 0.85,
          maxOutputTokens: isPremium ? 5000 : 3000,
          responseMimeType: 'application/json',
        },
      }),
    }
  )

  if (!res.ok) {
    const err = await res.text()
    throw new Error(`Gemini job recommendation failed: ${res.status} - ${err.slice(0, 200)}`)
  }
  const data = await res.json()
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text
  if (!text) throw new Error('Gemini returned no text for job recommendation')
  return parseJSON(text)
}

// Gemini 이미지 생성
async function generateJobImage(photoUrl, outfitPrompt, geminiKey, imageStyle = 'portrait') {
  const [header, b64Data] = photoUrl.split(',')
  const mimeType = header.split(':')[1].split(';')[0]

  const prompt = imageStyle === 'portrait'
    ? `Generate a professional portrait photo of the person in this reference image as a ${outfitPrompt}.

CRITICAL REQUIREMENTS:
- Keep the person's face, skin tone, and features identical to the reference photo
- Frame: head-to-waist upper body portrait, vertically centered with ample headroom
- The person's full head and face must be completely visible, never cropped at top
- Composition: centered subject, 3:4 vertical aspect ratio
- Background: realistic workplace environment for this profession
- Style: high-quality professional photography, warm natural lighting, sharp focus
- NO text, watermarks, logos, or overlays`
    : `Generate a full-body professional photo of the person in this reference image as a ${outfitPrompt}.

CRITICAL REQUIREMENTS:
- Keep the person's face, skin tone, and features identical to the reference photo
- Frame: FULL BODY from head to feet, the entire person must be visible
- Leave generous space above the head and below the feet
- Composition: centered subject, 4:3 horizontal landscape aspect ratio
- Show the person standing or sitting naturally in their workplace environment
- Background: realistic and detailed workplace setting for this profession
- Style: high-quality editorial photography, natural lighting, sharp focus
- NO text, watermarks, logos, or overlays`

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_IMAGE_MODEL}:generateContent?key=${geminiKey}`,
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

  if (!res.ok) {
    const errText = await res.text()
    throw new Error(`Gemini image failed: ${res.status} - ${errText.slice(0, 300)}`)
  }
  const data = await res.json()

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
    const { GEMINI_API_KEY } = context.env

    if (!GEMINI_API_KEY) {
      return new Response(JSON.stringify({ detail: 'GEMINI_API_KEY not configured' }), {
        status: 500, headers: { 'Content-Type': 'application/json', ...CORS_HEADERS },
      })
    }

    const body = await context.request.json()
    const { photo, mbti, mode } = body
    const analysisMode = mode === 'premium' ? 'premium' : 'basic'

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

    // Step 1: Face analysis (Gemini)
    const faceFeatures = await analyzeFace(photo, GEMINI_API_KEY, analysisMode)

    // Step 2: Job recommendations (Gemini)
    const jobResult = await recommendJobs(mbtiUpper, faceFeatures, GEMINI_API_KEY, analysisMode)

    // Step 3: Image generation (Gemini, parallel)
    // basic: 1등만, premium: 3개 모두
    const recsToGenerate = analysisMode === 'premium'
      ? (jobResult.recommendations || [])
      : (jobResult.recommendations || []).slice(0, 1)

    const imagePromises = recsToGenerate.map(async (rec) => {
      try {
        if (rec.outfit_prompt) {
          // 1등: 세로 portrait, 2·3등: 전신 landscape
          const style = rec.rank === 1 ? 'portrait' : 'fullbody'
          const imageUrl = await generateJobImage(photo, rec.outfit_prompt, GEMINI_API_KEY, style)
          rec.generated_image_url = imageUrl
        }
      } catch (e) {
        console.error(`Image generation failed for ${rec.job_name}:`, e.message)
        rec.generated_image_url = null
        rec.image_error = e.message
      }
    })
    await Promise.allSettled(imagePromises)

    const result = {
      analysis_id: crypto.randomUUID(),
      mode: analysisMode,
      face_features: faceFeatures,
      mbti: mbtiUpper,
      mbti_description: jobResult.mbti_description,
      element_job_insight: jobResult.element_job_insight || null,
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
