export async function analyzePhoto(photoDataUrl, mbti) {
  const response = await fetch('/api/analyze', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ photo: photoDataUrl, mbti }),
  })

  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: '분석 중 오류가 발생했습니다' }))
    throw new Error(error.detail || `Error: ${response.status}`)
  }

  return response.json()
}
