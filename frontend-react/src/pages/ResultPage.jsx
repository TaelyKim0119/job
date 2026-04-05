import { useState, useEffect } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { X, Quote, Briefcase, Brain, Wrench, PawPrint } from 'lucide-react'

function useIsMobile(bp = 520) {
  const [m, setM] = useState(() => window.innerWidth < bp)
  useEffect(() => {
    const h = () => setM(window.innerWidth < bp)
    window.addEventListener('resize', h)
    return () => window.removeEventListener('resize', h)
  }, [bp])
  return m
}

const MEDAL = [
  { color: '#B8860B', bg: 'rgba(184,134,11,0.10)', label: '1' },
  { color: '#78716C', bg: 'rgba(120,113,108,0.08)', label: '2' },
  { color: '#CD7F32', bg: 'rgba(205,127,50,0.08)', label: '3' },
]

const DEMO_RESULT = {
  face_features: {
    face_shape: '타원형', animal_type: '고양이상',
    animal_description: '날카로운 눈매와 갸름한 얼굴형이 도도하면서도 세련된 인상을 줍니다.',
    personality_summary: '삼정(三停)의 균형이 잘 잡혀 있고, 오관(五官)의 조화가 뛰어나 귀격의 상입니다.',
  },
  mbti: 'INTJ',
  mbti_description: 'INTJ는 전략적 사고와 독립적 판단을 중시하는 유형입니다.',
  recommendations: [
    { rank: 1, job_name: '향수 조향사', job_name_en: 'Perfumer', description: '세계적인 향수 브랜드에서 새로운 향기를 개발하는 전문가', face_reason: '넓은 이마와 섬세한 눈매는 높은 감각적 민감성과 창의력을 나타냅니다.', mbti_reason: '깊은 내면 세계와 예술적 감수성은 향기라는 보이지 않는 예술을 창조하는 데 최적입니다.', match_score: 94, skills: ['후각 민감성', '화학 지식', '창의력'] },
    { rank: 2, job_name: '게임 사운드 디자이너', job_name_en: 'Game Sound Designer', description: '게임 속 효과음과 배경 음악을 설계하고 구현하는 전문가', face_reason: '예리한 눈매와 균형 잡힌 턱선은 집중력과 분석력이 뛰어남을 보여줍니다.', mbti_reason: '독립적인 작업 스타일과 디테일에 대한 집착은 완벽한 사운드를 만들어내는 데 강점입니다.', match_score: 87, skills: ['음향 편집', 'DAW 활용', '게임 엔진'] },
    { rank: 3, job_name: '문화재 복원사', job_name_en: 'Art Conservator', description: '손상된 문화재와 예술 작품을 원래 상태로 복원하는 전문가', face_reason: '강한 턱선과 안정적인 얼굴형은 인내심과 끈기를 나타냅니다.', mbti_reason: '꼼꼼하고 체계적인 성격은 문화재를 정확하게 복원하는 데 이상적인 조합입니다.', match_score: 82, skills: ['미술사', '화학', '세밀한 수작업'] },
  ],
}

/* ── Score Ring ────────────────────────────── */
function ScoreRing({ score, color, size = 56 }) {
  const r = (size - 6) / 2
  const circ = 2 * Math.PI * r
  const offset = circ * (1 - score / 100)
  return (
    <div className="relative flex-shrink-0" style={{ width: size, height: size }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="rgba(0,0,0,0.06)" strokeWidth={4} />
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke={color} strokeWidth={4}
          strokeLinecap="round" strokeDasharray={circ} strokeDashoffset={offset}
          style={{ transition: 'stroke-dashoffset 1s ease' }} />
      </svg>
      <span className="absolute inset-0 flex items-center justify-center font-bold" style={{ color: '#fff', fontSize: size * 0.28 }}>
        {score}%
      </span>
    </div>
  )
}

/* ── Flip Card (Image → Detail) ───────────── */
function FlipJobCard({ job, medal, mbti, isMobile, isHero, height }) {
  const [flipped, setFlipped] = useState(false)

  const cardHeight = height || (isMobile ? 320 : 420)

  return (
    <div
      style={{ perspective: 1200, height: cardHeight }}
      className="w-full cursor-pointer"
      onClick={() => setFlipped(f => !f)}
    >
      <div style={{
        position: 'relative', width: '100%', height: '100%',
        transformStyle: 'preserve-3d',
        transition: 'transform 0.6s cubic-bezier(0.4, 0, 0.2, 1)',
        transform: flipped ? 'rotateY(180deg)' : 'rotateY(0deg)',
      }}>
        {/* ─── FRONT: Image ─── */}
        <div style={{
          position: 'absolute', inset: 0,
          backfaceVisibility: 'hidden', WebkitBackfaceVisibility: 'hidden',
          borderRadius: 16, overflow: 'hidden',
          border: isHero ? `2px solid ${medal.color}` : '1px solid var(--color-border-light)',
        }}>
          {isHero ? (
            /* ── 1등: 기존 cover 레이아웃 ── */
            <>
              {job.generated_image_url ? (
                <img src={job.generated_image_url} alt={job.job_name}
                  className="w-full h-full"
                  style={{ objectFit: 'cover', objectPosition: 'center top' }} />
              ) : (
                <div className="w-full h-full bg-gradient-to-br from-stone-100 to-stone-200 flex items-center justify-center">
                  <Briefcase size={48} className="text-stone-400" />
                </div>
              )}
              <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/10 to-transparent" />
              {/* 상단: 왼쪽 번호 + 오른쪽 퍼센트 */}
              <div className="absolute top-3 left-3 w-8 h-8 rounded-full flex items-center justify-center text-white font-bold"
                style={{ backgroundColor: medal.color, fontSize: 14 }}>
                {medal.label}
              </div>
              <span className="absolute top-3 right-3 text-white font-bold" style={{ fontSize: isMobile ? 14 : 18 }}>
                {job.match_score}<span className="text-white/50" style={{ fontSize: isMobile ? 10 : 12 }}>%</span>
              </span>
              {/* 하단: 직업명 중앙 */}
              <div className="absolute bottom-0 left-0 right-0 p-4">
                <div className="flex flex-col items-center text-center">
                  <p className="text-white/50 font-medium" style={{ fontSize: isMobile ? 11 : 14 }}>{job.job_name_en}</p>
                  <h3 className="text-white font-bold" style={{ fontSize: isMobile ? 20 : 28 }}>{job.job_name}</h3>
                </div>
              </div>
            </>
          ) : (
            /* ── 2·3등: 사진 왼쪽 정렬 + 오른쪽 검정 배경 ── */
            <>
              <div className="absolute inset-0" style={{ backgroundColor: '#111' }} />
              {job.generated_image_url ? (
                <img src={job.generated_image_url} alt={job.job_name}
                  className="absolute top-0 left-0 h-full"
                  style={{ objectFit: 'contain', objectPosition: 'left center' }} />
              ) : (
                <div className="w-full h-full bg-gradient-to-br from-stone-800 to-stone-900 flex items-center justify-center">
                  <Briefcase size={36} className="text-stone-600" />
                </div>
              )}
              {/* 하단 그라데이션 */}
              <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/10 to-transparent" />
              {/* 관상 그리드 오버레이 */}
              <img
                src="/images/face-analysis-grid.png"
                alt=""
                style={{
                  position: 'absolute',
                  top: '50%',
                  right: '10%',
                  transform: 'translateY(-50%)',
                  width: '50%',
                  height: 'auto',
                  opacity: 0.12,
                  mixBlendMode: 'lighten',
                  pointerEvents: 'none',
                }}
              />
              {/* 상단: 왼쪽 번호 + 오른쪽 퍼센트 */}
              <div className="absolute top-3 left-3 w-7 h-7 rounded-full flex items-center justify-center text-white font-bold"
                style={{ backgroundColor: medal.color, fontSize: 13 }}>
                {medal.label}
              </div>
              <span className="absolute top-3 right-3 font-bold" style={{ color: '#fff', fontSize: isMobile ? 13 : 16 }}>
                {job.match_score}<span style={{ color: 'rgba(255,255,255,0.5)', fontSize: isMobile ? 9 : 11 }}>%</span>
              </span>
              {/* 하단: 직업명 중앙 */}
              <div className="absolute bottom-0 left-0 right-0 p-4">
                <div className="flex flex-col items-center text-center">
                  <p className="text-white/50 font-medium" style={{ fontSize: isMobile ? 10 : 12 }}>{job.job_name_en}</p>
                  <h3 className="text-white font-bold" style={{ fontSize: isMobile ? 15 : 19 }}>{job.job_name}</h3>
                </div>
              </div>
            </>
          )}
        </div>

        {/* ─── BACK: Detail ─── */}
        <div style={{
          position: 'absolute', inset: 0,
          backfaceVisibility: 'hidden', WebkitBackfaceVisibility: 'hidden',
          transform: 'rotateY(180deg)',
          borderRadius: 16, overflow: 'hidden',
          border: isHero ? `2px solid ${medal.color}` : '1px solid var(--color-border-light)',
          backgroundColor: '#fff',
        }}>
          <div className="w-full h-full overflow-y-auto" style={{ padding: isMobile ? 16 : 24 }}>
            {/* Header row */}
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <span className="w-7 h-7 rounded-full flex items-center justify-center text-white text-xs font-bold"
                  style={{ backgroundColor: medal.color }}>{job.rank}</span>
                <div>
                  <h4 className="font-bold text-ink" style={{ fontSize: isMobile ? 17 : 22 }}>{job.job_name}</h4>
                  <p className="text-ink-tertiary" style={{ fontSize: isMobile ? 11 : 14 }}>{job.job_name_en}</p>
                </div>
              </div>
              <div className="w-6" />
            </div>

            {/* Match score */}
            <div className="mb-3">
              <span className="font-bold" style={{ color: medal.color, fontSize: isMobile ? 16 : 20 }}>매칭률 {job.match_score}%</span>
            </div>

            {/* Description */}
            <p className="text-ink-secondary leading-relaxed mb-4" style={{ fontSize: isMobile ? 14 : 17 }}>{job.description}</p>

            {/* Face reason */}
            <div className="p-3 rounded-xl mb-3" style={{ backgroundColor: medal.bg }}>
              <div className="flex items-center gap-1.5 mb-1.5">
                <PawPrint size={14} style={{ color: medal.color }} />
                <span className="font-semibold text-ink" style={{ fontSize: isMobile ? 13 : 16 }}>관상이 말하는 이유</span>
              </div>
              <p className="text-ink-secondary leading-relaxed" style={{ fontSize: isMobile ? 13 : 16 }}>{job.face_reason}</p>
            </div>

            {/* MBTI reason */}
            <div className="p-3 rounded-xl bg-surface mb-3">
              <div className="flex items-center gap-1.5 mb-1.5">
                <Brain size={14} className="text-brand-amber" />
                <span className="font-semibold text-ink" style={{ fontSize: isMobile ? 13 : 16 }}>{mbti}와 맞는 이유</span>
              </div>
              <p className="text-ink-secondary leading-relaxed" style={{ fontSize: isMobile ? 13 : 16 }}>{job.mbti_reason}</p>
            </div>

            {/* Skills */}
            <div className="flex items-center gap-1.5 mb-2">
              <Wrench size={14} className="text-brand-amber" />
              <span className="font-semibold text-ink" style={{ fontSize: isMobile ? 13 : 16 }}>필요한 스킬</span>
            </div>
            <div className="flex flex-wrap gap-1.5">
              {job.skills.map(s => (
                <span key={s} className="px-2.5 py-1 rounded-full bg-surface text-ink-secondary border border-border-light"
                  style={{ fontSize: isMobile ? 12 : 14 }}>{s}</span>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

/* ── Share Buttons ────────────────────────── */
const SHARE_URL = 'https://job-ccw.pages.dev'
const SHARE_TITLE = '직감(職感) - AI 관상 직업 매칭'
const SHARE_TEXT = 'AI가 내 얼굴과 MBTI를 분석해서 추천한 직업 TOP 3! 나에게 어울리는 직업은?'

const SHARE_ITEMS = [
  {
    label: 'Facebook',
    bg: '#1877F2', color: '#fff',
    svg: 'M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z',
    action: () => window.open(`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(SHARE_URL)}`, '_blank', 'width=600,height=400'),
  },
  {
    label: 'X',
    bg: '#000000', color: '#fff',
    svg: 'M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z',
    action: () => window.open(`https://twitter.com/intent/tweet?url=${encodeURIComponent(SHARE_URL)}&text=${encodeURIComponent(SHARE_TEXT)}`, '_blank', 'width=600,height=400'),
  },
  {
    label: '카카오톡',
    bg: '#FEE500', color: '#000',
    svg: 'M12 3c-5.523 0-10 3.582-10 8 0 2.808 1.867 5.276 4.674 6.68-.147.543-.543 1.97-.622 2.274-.095.37.136.365.287.266.118-.078 1.878-1.279 2.635-1.796A11.39 11.39 0 0 0 12 19c5.523 0 10-3.582 10-8s-4.477-8-10-8z',
    action: () => {
      if (navigator.share) {
        navigator.share({ title: SHARE_TITLE, text: SHARE_TEXT, url: SHARE_URL }).catch(() => {})
      } else {
        window.open(`https://www.kakaocorp.com/page/service/service/KakaoTalk`, '_blank')
      }
    },
  },
  {
    label: 'Telegram',
    bg: '#0088cc', color: '#fff',
    svg: 'M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z',
    action: () => window.open(`https://t.me/share/url?url=${encodeURIComponent(SHARE_URL)}&text=${encodeURIComponent(SHARE_TEXT)}`, '_blank', 'width=600,height=400'),
  },
  {
    label: 'LinkedIn',
    bg: '#0A66C2', color: '#fff',
    svg: 'M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z',
    action: () => window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(SHARE_URL)}`, '_blank', 'width=600,height=400'),
  },
  {
    label: '링크 복사',
    bg: '#6B7280', color: '#fff',
    svg: 'M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z',
    action: () => {
      navigator.clipboard.writeText(SHARE_URL).then(() => {
        alert('링크가 복사되었습니다!')
      }).catch(() => {
        const ta = document.createElement('textarea')
        ta.value = SHARE_URL
        document.body.appendChild(ta)
        ta.select()
        document.execCommand('copy')
        document.body.removeChild(ta)
        alert('링크가 복사되었습니다!')
      })
    },
  },
]

function ShareButtons() {
  return (
    <div className="flex items-center justify-center gap-3 flex-wrap">
      <span className="text-sm font-semibold text-ink-secondary">공유하기</span>
      <div className="flex gap-2">
        {SHARE_ITEMS.map(item => (
          <button
            key={item.label}
            onClick={item.action}
            title={item.label}
            className="w-10 h-10 rounded-full flex items-center justify-center transition-all hover:-translate-y-0.5 hover:shadow-lg active:scale-95"
            style={{ backgroundColor: item.bg, color: item.color }}
          >
            <svg viewBox="0 0 24 24" style={{ width: 20, height: 20, fill: 'currentColor' }}>
              <path d={item.svg} />
            </svg>
          </button>
        ))}
      </div>
    </div>
  )
}

/* ── Main Page ────────────────────────────── */
export default function ResultPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const isMobile = useIsMobile()

  const result = location.state?.result || DEMO_RESULT
  const error = location.state?.error

  const face = result?.face_features
  const jobs = result?.recommendations || []
  const mbti = result?.mbti || 'INTJ'
  const isPremium = result?.mode === 'premium'
  const elementInsight = result?.element_job_insight
  const photoUrl = localStorage.getItem('photoDataUrl')

  if (error) {
    return (
      <div className="min-h-screen bg-canvas flex flex-col items-center justify-center px-6 text-center">
        <p className="text-lg font-semibold text-ink mb-2">분석 실패</p>
        <p className="text-sm text-ink-secondary mb-6">{error}</p>
        <button onClick={() => navigate('/')} className="px-6 py-3 bg-ink text-ink-inverted rounded-xl font-medium">처음으로</button>
      </div>
    )
  }

  const maxW = isMobile ? '100%' : 860
  const px = isMobile ? 20 : 0

  return (
    <div className="min-h-screen bg-canvas">
      {/* ── Dark Header ─────────────────────── */}
      <div style={{
        background: 'linear-gradient(145deg, #1C1917 0%, #292524 100%)',
        paddingTop: 'max(16px, env(safe-area-inset-top))',
      }}>
        <div style={{ maxWidth: maxW, margin: '0 auto', padding: `0 ${px}px` }}>
          <div className="flex items-center justify-between py-3">
            <button onClick={() => navigate('/')} className="p-1 text-white/60 hover:text-white transition-colors"><X size={22} /></button>
            <div className="w-8" />
          </div>

          <div className="flex items-center gap-4 pb-5">
            {photoUrl && (
              <div className="flex-shrink-0 rounded-full overflow-hidden"
                style={{ width: isMobile ? 56 : 68, height: isMobile ? 56 : 68, border: '2px solid rgba(184,134,11,0.6)' }}>
                <img src={photoUrl} alt="" className="w-full h-full object-cover" />
              </div>
            )}
            <div>
              <div className="flex items-center gap-2 flex-wrap">
                <h1 className="text-white font-bold" style={{ fontSize: isMobile ? 20 : 28 }}>당신의 직업 DNA</h1>
                <div className="flex items-center gap-1.5" style={{ color: '#D4A017' }}>
                  <Briefcase size={isMobile ? 14 : 18} />
                  <span className="font-bold" style={{ fontSize: isMobile ? 14 : 18 }}>TOP 3</span>
                </div>
              </div>
              <div className="flex items-center gap-2 mt-1.5 flex-wrap">
                <span className="px-2.5 py-0.5 rounded-md text-xs font-bold tracking-wide"
                  style={{ backgroundColor: 'rgba(184,134,11,0.2)', color: '#D4A017' }}>{mbti}</span>
                {isPremium && (
                  <span className="px-2 py-0.5 rounded-md text-[10px] font-bold tracking-wide"
                    style={{ backgroundColor: 'rgba(212,160,23,0.3)', color: '#F5D76E' }}>PREMIUM</span>
                )}
                {face?.face_shape && (
                  <span className="text-white/40 text-xs">{face.face_shape}</span>
                )}
                {face?.animal_type && (
                  <span className="text-white/40 text-xs">· {face.animal_type}</span>
                )}
                {isPremium && face?.element_type && (
                  <span className="text-white/40 text-xs">· {face.element_type}</span>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ── Content ─────────────────────────── */}
      <div style={{ maxWidth: maxW, margin: '0 auto', padding: `0 ${px}px` }}>

        {/* Animal & Personality Summary */}
        <div style={{
          display: 'grid',
          gridTemplateColumns: isMobile ? '1fr' : (face?.animal_type && face?.personality_summary ? '1fr 1fr' : '1fr'),
          gap: isMobile ? 14 : 20,
          marginTop: isMobile ? 20 : 28,
        }}>
          {face?.animal_type && (
            <div className="bg-white rounded-2xl border border-border-light"
              style={{ padding: isMobile ? '20px 20px 24px' : '28px 28px 32px' }}>
              <div className="flex items-center justify-between" style={{ marginBottom: isMobile ? 14 : 18 }}>
                <div className="flex items-center gap-2">
                  <PawPrint size={isMobile ? 18 : 20} className="text-brand-amber" />
                  <span className="font-bold text-ink" style={{ fontSize: isMobile ? 16 : 20 }}>동물상</span>
                </div>
                <span className="px-3 py-1 rounded-full font-bold"
                  style={{ backgroundColor: 'rgba(184,134,11,0.1)', color: '#B8860B', fontSize: isMobile ? 14 : 16 }}>{face.animal_type}</span>
              </div>
              {face.animal_description && (
                <p className="text-ink-secondary" style={{ fontSize: isMobile ? 15 : 17, lineHeight: 1.75 }}>{face.animal_description}</p>
              )}
            </div>
          )}
          {face?.personality_summary && (
            <div className="bg-white rounded-2xl border border-border-light"
              style={{ padding: isMobile ? '20px 20px 24px' : '28px 28px 32px' }}>
              <div className="flex items-center gap-2" style={{ marginBottom: isMobile ? 14 : 18 }}>
                <Quote size={isMobile ? 16 : 18} className="text-brand-amber" />
                <span className="font-bold text-ink" style={{ fontSize: isMobile ? 16 : 20 }}>관상 총평</span>
              </div>
              <p className="text-ink-secondary" style={{ fontSize: isMobile ? 15 : 17, lineHeight: 1.75 }}>{face.personality_summary}</p>
            </div>
          )}
        </div>

        {/* ── Premium: 오행·삼정·기색 ──── */}
        {isPremium && (face?.element_type || face?.samjeong_ratio || face?.complexion || elementInsight) && (
          <div style={{
            display: 'grid',
            gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr',
            gap: isMobile ? 12 : 16,
            marginTop: isMobile ? 12 : 16,
          }}>
            {face?.element_type && (
              <div className="p-4 rounded-2xl border" style={{ backgroundColor: '#1C1917', borderColor: 'rgba(184,134,11,0.3)' }}>
                <div className="flex items-center gap-2 mb-2">
                  <span style={{ color: '#D4A017', fontSize: 16 }}>✦</span>
                  <span className="font-bold" style={{ color: '#fff', fontSize: isMobile ? 15 : 18 }}>오행 체질</span>
                  <span className="px-2 py-0.5 rounded-full text-xs font-bold" style={{ backgroundColor: 'rgba(184,134,11,0.2)', color: '#D4A017' }}>{face.element_type}</span>
                </div>
                {elementInsight && (
                  <p style={{ color: 'rgba(255,255,255,0.7)', fontSize: isMobile ? 13 : 15, lineHeight: 1.6 }}>{elementInsight}</p>
                )}
              </div>
            )}
            {face?.samjeong_ratio && (
              <div className="p-4 rounded-2xl border" style={{ backgroundColor: '#1C1917', borderColor: 'rgba(184,134,11,0.3)' }}>
                <div className="flex items-center gap-2 mb-2">
                  <span style={{ color: '#D4A017', fontSize: 16 }}>☰</span>
                  <span className="font-bold" style={{ color: '#fff', fontSize: isMobile ? 15 : 18 }}>삼정 비율</span>
                </div>
                <p style={{ color: 'rgba(255,255,255,0.7)', fontSize: isMobile ? 13 : 15, lineHeight: 1.6 }}>{face.samjeong_ratio}</p>
              </div>
            )}
            {face?.complexion && (
              <div className="p-4 rounded-2xl border" style={{ backgroundColor: '#1C1917', borderColor: 'rgba(184,134,11,0.3)' }}>
                <div className="flex items-center gap-2 mb-2">
                  <span style={{ color: '#D4A017', fontSize: 16 }}>◐</span>
                  <span className="font-bold" style={{ color: '#fff', fontSize: isMobile ? 15 : 18 }}>기색 분석</span>
                </div>
                <p style={{ color: 'rgba(255,255,255,0.7)', fontSize: isMobile ? 13 : 15, lineHeight: 1.6 }}>{face.complexion}</p>
              </div>
            )}
            {face?.eyebrows && (
              <div className="p-4 rounded-2xl border" style={{ backgroundColor: '#1C1917', borderColor: 'rgba(184,134,11,0.3)' }}>
                <div className="flex items-center gap-2 mb-2">
                  <span style={{ color: '#D4A017', fontSize: 16 }}>〰</span>
                  <span className="font-bold" style={{ color: '#fff', fontSize: isMobile ? 15 : 18 }}>눈썹 · 보수관</span>
                </div>
                <p style={{ color: 'rgba(255,255,255,0.7)', fontSize: isMobile ? 13 : 15, lineHeight: 1.6 }}>{face.eyebrows}</p>
              </div>
            )}
          </div>
        )}

        {/* ── Job Flip Cards ──────────────── */}
        <div style={{ marginTop: isMobile ? 24 : 36, marginBottom: 16 }}>
          {isPremium ? (
            /* ── Premium: 1등 왼쪽 큰 사진 + 2,3등 오른쪽 세로 배치 ── */
            <>
              {isMobile ? (
                /* 모바일: 세로 배치 — 1등 크게, 2·3등 가로 나란히 */
                <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                  {jobs[0] && (
                    <FlipJobCard job={jobs[0]} medal={MEDAL[0]} mbti={mbti} isMobile={isMobile} isHero height={360} />
                  )}
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                    {jobs.slice(1, 3).map((job, i) => (
                      <FlipJobCard key={job.rank} job={job} medal={MEDAL[i + 1]} mbti={mbti} isMobile={isMobile} isHero={false} height={220} />
                    ))}
                  </div>
                </div>
              ) : (
                /* 데스크탑: 참고 이미지처럼 좌 1등 + 우 2·3등 */
                <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1fr', gap: 14, height: 520 }}>
                  {/* 1등: 왼쪽 전체 높이 */}
                  {jobs[0] && (
                    <FlipJobCard job={jobs[0]} medal={MEDAL[0]} mbti={mbti} isMobile={isMobile} isHero height={520} />
                  )}
                  {/* 2·3등: 오른쪽 위아래 */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 14, height: '100%' }}>
                    {jobs.slice(1, 3).map((job, i) => (
                      <FlipJobCard key={job.rank} job={job} medal={MEDAL[i + 1]} mbti={mbti} isMobile={isMobile} isHero={false} height={253} />
                    ))}
                  </div>
                </div>
              )}
            </>
          ) : (
            /* ── Basic: 1등만 + 잠긴 2·3등 ── */
            <>
              {isMobile ? (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
                  {jobs[0] && (
                    <FlipJobCard job={jobs[0]} medal={MEDAL[0]} mbti={mbti} isMobile={isMobile} isHero height={360} />
                  )}
                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                    {jobs.slice(1, 3).map((job, i) => (
                      <div key={job.rank} className="rounded-2xl flex flex-col items-center justify-center"
                        style={{ height: 220, backgroundColor: '#111' }}>
                        <span style={{
                          fontSize: 36, lineHeight: 1,
                          color: 'rgba(255,255,255,0.25)',
                          fontWeight: 600,
                        }}>?</span>
                        <span style={{
                          fontSize: 48, lineHeight: 1,
                          color: 'rgba(255,255,255,0.4)',
                          fontWeight: 800,
                          marginTop: 6,
                        }}>{MEDAL[i + 1].label}</span>
                      </div>
                    ))}
                  </div>
                </div>
              ) : (
                <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 1fr', gap: 14, height: 520 }}>
                  {jobs[0] && (
                    <FlipJobCard job={jobs[0]} medal={MEDAL[0]} mbti={mbti} isMobile={isMobile} isHero height={520} />
                  )}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 14, height: '100%' }}>
                    {jobs.slice(1, 3).map((job, i) => (
                      <div key={job.rank} className="rounded-2xl flex flex-col items-center justify-center"
                        style={{ height: 253, backgroundColor: '#111' }}>
                        <span style={{
                          fontSize: 44, lineHeight: 1,
                          color: 'rgba(255,255,255,0.25)',
                          fontWeight: 600,
                        }}>?</span>
                        <span style={{
                          fontSize: 56, lineHeight: 1,
                          color: 'rgba(255,255,255,0.4)',
                          fontWeight: 800,
                          marginTop: 8,
                        }}>{MEDAL[i + 1].label}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
              {/* Upsell banner */}
              <div className="rounded-2xl overflow-hidden"
                style={{ border: '1px solid rgba(0,0,0,0.1)', marginTop: isMobile ? 24 : 32 }}>
                <div style={{ backgroundColor: '#fff', padding: isMobile ? '16px 18px 12px' : '20px 24px 14px' }}>
                  <p style={{
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: 600,
                    letterSpacing: '0.08em',
                    textTransform: 'uppercase',
                    color: 'rgba(0,0,0,0.35)',
                    marginBottom: 6,
                  }}>고급 분석</p>
                  <p className="font-bold" style={{ fontSize: isMobile ? 17 : 20, color: '#111', lineHeight: 1.3 }}>
                    나머지 직업 2개가<br />아직 잠겨있어요
                  </p>
                  <p style={{
                    color: 'rgba(0,0,0,0.45)',
                    fontSize: isMobile ? 13 : 14,
                    marginTop: 6,
                    lineHeight: 1.55,
                  }}>
                    삼정·오행·기색 심층 분석과 함께<br />
                    3개 직업 전부를 AI 이미지로 확인하세요
                  </p>
                </div>
                <div style={{
                  padding: isMobile ? '14px 18px 18px' : '16px 24px 22px',
                }}>
                  <button
                    onClick={() => { navigate('/mbti') }}
                    className="w-full font-bold active:scale-[0.98] transition-transform"
                    style={{
                      backgroundColor: '#111',
                      color: '#fff',
                      fontSize: isMobile ? 15 : 16,
                      padding: isMobile ? '14px 0' : '16px 0',
                      borderRadius: 12,
                      letterSpacing: '-0.01em',
                    }}
                  >
                    고급 분석 →
                  </button>
                </div>
              </div>
            </>
          )}
        </div>

        {/* ── Share & Actions ────────────────── */}
        <div className="py-6 border-t border-border-light mt-4" style={{ marginBottom: 'max(16px, env(safe-area-inset-bottom))' }}>
          <ShareButtons />
          <button
            onClick={() => { localStorage.removeItem('photoDataUrl'); localStorage.removeItem('returnTo'); navigate('/') }}
            className="rounded-2xl border border-border-light text-ink-secondary font-semibold hover:bg-surface transition-colors mt-5 active:scale-[0.97]"
            style={{
              fontSize: isMobile ? 14 : 16,
              width: isMobile ? '60%' : '240px',
              margin: '20px auto 0',
              display: 'block',
              padding: '16px 0',
            }}
          >
            다시 분석하기
          </button>
        </div>
      </div>
    </div>
  )
}
