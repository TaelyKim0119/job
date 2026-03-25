import { useState, useId } from 'react'
import { useNavigate } from 'react-router-dom'
import { ChevronLeft, ArrowRight, Camera, Image as ImageIcon, CheckCircle, Lightbulb } from 'lucide-react'

function resizeImage(dataUrl, maxWidth = 600) {
  return new Promise((resolve, reject) => {
    const img = new window.Image()
    img.onload = () => {
      try {
        const canvas = document.createElement('canvas')
        let { width, height } = img
        if (width > maxWidth) {
          height = (height * maxWidth) / width
          width = maxWidth
        }
        canvas.width = width
        canvas.height = height
        const ctx = canvas.getContext('2d')
        ctx.drawImage(img, 0, 0, width, height)
        resolve(canvas.toDataURL('image/jpeg', 0.6))
      } catch (err) {
        reject(err)
      }
    }
    img.onerror = () => reject(new Error('이미지 로드 실패'))
    img.src = dataUrl
  })
}

function readFileAsDataUrl(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(reader.result)
    reader.onerror = () => reject(new Error('파일 읽기 실패'))
    reader.readAsDataURL(file)
  })
}

export default function PhotoPage() {
  const navigate = useNavigate()
  const [photoPreview, setPhotoPreview] = useState(() => {
    return localStorage.getItem('photoDataUrl') || null
  })
  const [loading, setLoading] = useState(false)
  const cameraId = useId()
  const galleryId = useId()

  async function handleFileSelect(e) {
    const file = e.target.files?.[0]
    if (!file) return
    setLoading(true)
    try {
      const rawDataUrl = await readFileAsDataUrl(file)
      const dataUrl = await resizeImage(rawDataUrl)
      localStorage.setItem('photoDataUrl', dataUrl)
      setPhotoPreview(dataUrl)
    } catch (err) {
      console.error('Photo error:', err)
      alert('사진을 불러올 수 없습니다. 다시 시도해주세요.')
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

      {/* 스텝 인디케이터 */}
      <div className="px-28 pt-0 pb-1">
        <div className="flex items-center">
          <div className="w-6 h-6 rounded-full bg-ink text-ink-inverted flex items-center justify-center text-[11px] font-bold">1</div>
          <div className="flex-1 h-px bg-border-light mx-2" />
          <div className="w-6 h-6 rounded-full bg-surface border border-border-light text-ink-tertiary flex items-center justify-center text-[11px] font-bold">2</div>
        </div>
        <div className="flex justify-between mt-1">
          <span className="text-[11px] font-medium text-brand-amber">사진</span>
          <span className="text-[11px] text-ink-tertiary">MBTI</span>
        </div>
      </div>

      <div className="flex-1 px-6 flex flex-col items-center pt-3 min-h-0 overflow-auto">
        {loading ? (
          <div className="flex flex-col items-center gap-3">
            <div className="w-10 h-10 border-2 border-brand-amber border-t-transparent rounded-full animate-spin" />
            <p className="text-sm text-ink-secondary">사진 처리 중...</p>
          </div>
        ) : photoPreview ? (
          <div className="w-full max-w-[200px] flex flex-col items-center">
            <div className="relative w-full aspect-square rounded-2xl overflow-hidden border-2 border-success bg-surface">
              <img src={photoPreview} alt="선택된 사진" className="w-full h-full object-cover" />
              <div className="absolute bottom-3 left-0 right-0 flex justify-center">
                <div className="bg-white/90 border border-border-light rounded-full px-3 py-1.5 flex items-center gap-1.5">
                  <CheckCircle size={14} className="text-success" />
                  <span className="text-xs font-medium text-success">사진 준비 완료</span>
                </div>
              </div>
            </div>
            <button onClick={handleReset} className="mt-2 text-sm text-ink-tertiary hover:text-ink-secondary transition-colors">
              다시 선택하기
            </button>
          </div>
        ) : (
          <div className="flex flex-col items-center gap-4 w-full max-w-sm">
            <label
              htmlFor={galleryId}
              className="w-36 h-36 rounded-full border-2 border-border-strong bg-surface-light flex flex-col items-center justify-center gap-2 hover:border-brand-amber hover:bg-brand-amber-bg/30 transition-all active:scale-95 cursor-pointer"
            >
              <ImageIcon size={32} className="text-brand-amber" />
              <div className="text-center">
                <p className="text-sm font-semibold text-ink">사진 선택</p>
                <p className="text-[11px] text-ink-tertiary mt-0.5">갤러리에서 골라주세요</p>
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

            <label
              htmlFor={cameraId}
              className="flex items-center gap-2 px-5 py-2.5 rounded-xl border border-border-light text-ink-secondary hover:bg-surface transition-colors active:scale-95 cursor-pointer"
            >
              <Camera size={16} />
              <span className="text-sm font-medium">카메라로 촬영</span>
              <input
                id={cameraId}
                type="file"
                accept="image/*"
                capture="environment"
                onChange={handleFileSelect}
                className="absolute w-0 h-0 opacity-0 overflow-hidden"
                style={{ position: 'absolute', width: 0, height: 0, opacity: 0, overflow: 'hidden' }}
              />
            </label>

            <div className="w-full bg-surface rounded-xl border border-border-light p-3 flex items-start gap-2.5">
              <Lightbulb size={16} className="text-brand-amber flex-shrink-0 mt-0.5" />
              <p className="text-xs text-ink-secondary">정면 사진이 가장 정확한 분석 결과를 제공합니다</p>
            </div>
          </div>
        )}
      </div>

      {photoPreview && !loading && (
        <div className="px-6 py-4">
          <button
            onClick={handleNext}
            className="w-full py-3.5 rounded-2xl bg-ink text-ink-inverted font-semibold flex items-center justify-center gap-2 active:scale-[0.98] transition-all"
          >
            다음으로
            <ArrowRight size={18} />
          </button>
        </div>
      )}
    </div>
  )
}
