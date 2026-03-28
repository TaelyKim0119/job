import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { ChevronLeft, ArrowRight } from 'lucide-react'

const MBTI_TYPES = [
  'INTJ', 'INTP', 'ENTJ', 'ENTP',
  'INFJ', 'INFP', 'ENFJ', 'ENFP',
  'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
  'ISTP', 'ISFP', 'ESTP', 'ESFP',
]

const MBTI_NAMES = {
  INTJ: '전략가', INTP: '논리술사', ENTJ: '통솔자', ENTP: '변론가',
  INFJ: '옹호자', INFP: '중재자', ENFJ: '선도자', ENFP: '활동가',
  ISTJ: '현실주의자', ISFJ: '수호자', ESTJ: '경영자', ESFJ: '집정관',
  ISTP: '장인', ISFP: '모험가', ESTP: '사업가', ESFP: '연예인',
}

function FlipCard({ type, name, isSelected, onSelect }) {
  return (
    <div
      onClick={() => onSelect(type)}
      className="cursor-pointer"
      style={{ perspective: '600px', height: '120px' }}
    >
      <div
        style={{
          position: 'relative',
          width: '100%',
          height: '100%',
          transformStyle: 'preserve-3d',
          transition: 'transform 0.5s ease',
          transform: isSelected ? 'rotateY(180deg)' : 'rotateY(0deg)',
        }}
      >
        {/* 앞면 — MBTI 코드 */}
        <div
          className="absolute inset-0 rounded-xl flex items-center justify-center text-[13px] font-extrabold bg-surface text-ink border border-border-light"
          style={{ backfaceVisibility: 'hidden', letterSpacing: '-0.3px' }}
        >
          {type}
        </div>

        {/* 뒷면 — MBTI 코드 + 이름 */}
        <div
          className="absolute inset-0 rounded-xl flex flex-col items-center justify-center bg-ink text-white shadow-sm"
          style={{ backfaceVisibility: 'hidden', transform: 'rotateY(180deg)' }}
        >
          <span className="text-[13px] font-extrabold" style={{ letterSpacing: '-0.3px' }}>{type}</span>
          <span className="text-[10px] font-medium opacity-70 mt-0.5">{name}</span>
        </div>
      </div>
    </div>
  )
}

export default function MbtiPage() {
  const navigate = useNavigate()
  const [selected, setSelected] = useState(null)

  function handleSubmit(mode = 'basic') {
    if (!selected) return
    const photoDataUrl = localStorage.getItem('photoDataUrl')
    navigate('/analyzing', { state: { mbti: selected, photoDataUrl, mode } })
  }

  return (
    <div className="min-h-screen bg-canvas flex flex-col">
      <header className="flex items-center px-4 py-3">
        <button
          onClick={() => navigate(-1)}
          className="p-2 -ml-2 text-ink hover:text-ink-secondary transition-colors"
        >
          <ChevronLeft size={24} />
        </button>
      </header>

      <div className="px-6 pt-4 pb-6">
        <h1 className="text-2xl font-bold text-ink">당신의 성격유형은?</h1>
        <p className="text-sm text-ink-tertiary mt-1">
          MBTI를 모른다면 직관적으로 골라보세요
        </p>
      </div>

      <div className="px-6">
        <div className="grid grid-cols-4 gap-1.5">
          {MBTI_TYPES.map((type) => (
            <FlipCard
              key={type}
              type={type}
              name={MBTI_NAMES[type]}
              isSelected={selected === type}
              onSelect={setSelected}
            />
          ))}
        </div>

        <div className="flex gap-2.5 mt-5">
          <button
            onClick={() => handleSubmit('basic')}
            disabled={!selected}
            className={`
              flex-[4] py-3 rounded-xl font-semibold text-[15px]
              flex items-center justify-center gap-1.5 transition-all duration-200
              ${selected
                ? 'bg-border-strong text-ink active:scale-[0.98]'
                : 'bg-border-light text-ink-tertiary cursor-not-allowed'
              }
            `}
          >
            분석 시작
            <ArrowRight size={16} />
          </button>
          <button
            onClick={() => handleSubmit('premium')}
            disabled={!selected}
            className={`
              flex-[6] py-3 rounded-xl font-semibold text-[15px]
              flex items-center justify-center gap-1.5 transition-all duration-200
              ${selected
                ? 'active:scale-[0.98]'
                : 'cursor-not-allowed'
              }
            `}
            style={{
              backgroundColor: selected ? '#B8860B' : undefined,
              color: selected ? '#FFFFFF' : undefined,
            }}
          >
            고급 분석
            <span className="text-[11px] font-normal" style={{ color: selected ? 'rgba(255,255,255,0.85)' : undefined }}>심층 감정</span>
          </button>
        </div>
      </div>
    </div>
  )
}
