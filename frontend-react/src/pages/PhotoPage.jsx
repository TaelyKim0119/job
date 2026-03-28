import { useState, useEffect, useId } from 'react'
import { useNavigate } from 'react-router-dom'
import { ChevronLeft, ArrowRight, Image as ImageIcon, CheckCircle, Lightbulb } from 'lucide-react'

// objectUrl 또는 dataUrl을 받아 리사이즈
function resizeImage(src, maxWidth = 600) {
  return new Promise((resolve, reject) => {
    const img = new window.Image()
    img.onload = () => {
      try {
        const canvas = document.createElement('canvas')
        let { width, height } = img
        if (width > maxWidth) {
          height = Math.round((height * maxWidth) / width)
          width = maxWidth
        }
        canvas.width = width
        canvas.height = height
        canvas.getContext('2d').drawImage(img, 0, 0, width, height)
        resolve(canvas.toDataURL('image/jpeg', 0.6))
      } catch (err) {
        reject(err)
      }
    }
    img.onerror = () => reject(new Error('이미지 디코딩 실패'))
    img.src = src
  })
}

export default function PhotoPage() {
  const navigate = useNavigate()
  const [photoPreview, setPhotoPreview] = useState(() => {
    return localStorage.getItem('photoDataUrl') || null
  })
  const [loading, setLoading] = useState(false)
  const galleryId = useId()

  // 모바일: 카메라 열면 페이지가 리로드 → /photo로 복귀하도록
  useEffect(() => {
    localStorage.setItem('returnTo', '/photo')
    return () => {}
  }, [])

  async function handleFileSelect(e) {
    const file = e.target.files?.[0]
    if (!file) return
    setLoading(true)
    try {
      let dataUrl

      // HEIC 감지 (삼성 카메라 기본 포맷)
      const isHeic = ['image/heic', 'image/heif'].includes(file.type)
        || /\.(heic|heif)$/i.test(file.name || '')

      if (isHeic) {
        // HEIC → JPEG 변환 (타임아웃 15초)
        const heic2any = (await import('heic2any')).default
        const convertPromise = heic2any({ blob: file, toType: 'image/jpeg', quality: 0.8 })
        const timeoutPromise = new Promise((_, reject) =>
          setTimeout(() => reject(new Error('HEIC 변환 시간 초과')), 15000)
        )
        const blob = await Promise.race([convertPromise, timeoutPromise])
        const objectUrl = URL.createObjectURL(blob)
        try {
          dataUrl = await resizeImage(objectUrl)
        } finally {
          URL.revokeObjectURL(objectUrl)
        }
      } else {
        // 일반 이미지: ObjectURL로 메모리 복사 없이 처리
        const objectUrl = URL.createObjectURL(file)
        try {
          dataUrl = await resizeImage(objectUrl)
        } finally {
          URL.revokeObjectURL(objectUrl)
        }
      }

      try {
        localStorage.setItem('photoDataUrl', dataUrl)
      } catch {
        // localStorage 용량 초과 시 더 작게 리사이즈
        const objectUrl = URL.createObjectURL(file)
        try {
          dataUrl = await resizeImage(objectUrl, 300)
        } finally {
          URL.revokeObjectURL(objectUrl)
        }
        localStorage.setItem('photoDataUrl', dataUrl)
      }
      setPhotoPreview(dataUrl)
    } catch (err) {
      console.error('Photo error:', err)
      alert('사진을 불러올 수 없습니다.\n갤러리에서 사진을 선택해주세요.')
    } finally {
      setLoading(false)
      e.target.value = ''
    }
  }

  function handleNext() {
    if (!photoPreview) return
    localStorage.removeItem('returnTo')
    navigate('/mbti')
  }

  function handleReset() {
    setPhotoPreview(null)
    localStorage.removeItem('photoDataUrl')
  }

  return (
    <div className="h-screen bg-canvas flex flex-col overflow-hidden">
      <header className="flex items-center justify-between px-4 py-3">
        <button onClick={() => { localStorage.removeItem('returnTo'); navigate(-1) }} className="p-2 -ml-2 text-ink hover:text-ink-secondary transition-colors">
          <ChevronLeft size={24} />
        </button>
        <span className="text-base font-semibold text-ink">사진 선택</span>
        <div className="w-10" />
      </header>

      <div className="flex-1 px-6 flex flex-col items-center justify-center min-h-0 overflow-auto">
        {loading ? (
          <div className="flex flex-col items-center gap-3">
            <div className="w-10 h-10 border-2 border-brand-amber border-t-transparent rounded-full animate-spin" />
            <p className="text-sm text-ink-secondary">사진 처리 중...</p>
          </div>
        ) : photoPreview ? (
          <div className="w-full max-w-[400px] flex flex-col items-center">
            {/* 스텝 인디케이터 */}
            <div className="flex justify-center" style={{ marginBottom: 24, width: 120 }}>
              <div style={{ width: '100%' }}>
                <div className="flex items-center">
                  <div className="w-6 h-6 rounded-full bg-ink text-ink-inverted flex items-center justify-center text-[11px] font-bold">1</div>
                  <div className="mx-2" style={{ flex: 1, borderTop: '2px dashed var(--color-border-light)' }} />
                  <div className="w-6 h-6 rounded-full bg-surface border border-border-light text-ink-tertiary flex items-center justify-center text-[11px] font-bold">2</div>
                </div>
                <div className="flex justify-between mt-0.5">
                  <span className="text-[10px] font-medium text-brand-amber">사진</span>
                  <span className="text-[10px] text-ink-tertiary">MBTI</span>
                </div>
              </div>
            </div>
            <div className="relative w-full aspect-square rounded-2xl overflow-hidden border-2 border-success bg-surface">
              <img src={photoPreview} alt="선택된 사진" className="w-full h-full object-cover" />
              <div className="absolute bottom-3 left-0 right-0 flex justify-center">
                <div className="bg-white/90 border border-border-light rounded-full px-3 py-1.5 flex items-center gap-1.5">
                  <CheckCircle size={20} className="text-success" />
                  <span className="text-sm font-medium text-success">사진 준비 완료</span>
                </div>
              </div>
            </div>
            <button onClick={handleReset} className="mt-4 text-base text-ink-tertiary hover:text-ink-secondary transition-colors">
              다시 선택하기
            </button>
            <button
              onClick={handleNext}
              className="mt-6 w-full py-3.5 rounded-2xl bg-ink text-ink-inverted font-semibold flex items-center justify-center gap-2 active:scale-[0.98] transition-all"
            >
              다음으로
              <ArrowRight size={18} />
            </button>
          </div>
        ) : (
          <div className="flex flex-col items-center gap-4 w-full max-w-sm">
            {/* 스텝 인디케이터 */}
            <div style={{ width: 120 }}>
              <div className="flex items-center">
                <div className="w-6 h-6 rounded-full bg-ink text-ink-inverted flex items-center justify-center text-[11px] font-bold">1</div>
                <div className="mx-2" style={{ flex: 1, borderTop: '2px dashed var(--color-border-light)' }} />
                <div className="w-6 h-6 rounded-full bg-surface border border-border-light text-ink-tertiary flex items-center justify-center text-[11px] font-bold">2</div>
              </div>
              <div className="flex justify-between mt-0.5">
                <span className="text-[10px] font-medium text-brand-amber">사진</span>
                <span className="text-[10px] text-ink-tertiary">MBTI</span>
              </div>
            </div>
            <label
              htmlFor={galleryId}
              className="w-72 h-72 rounded-full border-2 border-border-strong bg-surface-light flex flex-col items-center justify-center gap-3 hover:border-brand-amber hover:bg-brand-amber-bg/30 transition-all active:scale-95 cursor-pointer"
            >
              <ImageIcon size={56} className="text-brand-amber" />
              <div className="text-center">
                <p className="text-xl font-semibold text-ink">사진 선택</p>
                <p className="text-sm text-ink-tertiary mt-1">갤러리에서 선택</p>
              </div>
              <input
                id={galleryId}
                type="file"
                accept="image/*"
                onChange={handleFileSelect}
                className="absolute w-0 h-0 opacity-0 overflow-hidden"
                style={{ position: 'absolute', width: 0, height: 0, opacity: 0, overflow: 'hidden' }}
              />
            </label>

            <div className="w-full bg-surface rounded-xl border border-border-light p-4 flex items-start gap-3">
              <Lightbulb size={22} className="text-brand-amber flex-shrink-0 mt-0.5" />
              <p className="text-sm text-ink-secondary">정면 사진이 가장 정확한 분석 결과를 제공합니다</p>
            </div>
          </div>
        )}
      </div>

    </div>
  )
}
