import { useState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { X, Quote, Briefcase, Brain, Wrench, PawPrint, Share2 } from 'lucide-react'

const MEDAL_COLORS = ['#B8860B', '#78716C', '#CD7F32']

const DEMO_RESULT = {
  face_features: {
    face_shape: '타원형', animal_type: '고양이상',
    animal_description: '날카로운 눈매와 갸름한 얼굴형이 도도하면서도 세련된 인상을 줍니다.',
    personality_summary: '삼정(三停)의 균형이 잘 잡혀 있고, 오관(五官)의 조화가 뛰어나 귀격의 상입니다.',
  },
  mbti: 'INTJ',
  mbti_description: 'INTJ는 전략적 사고와 독립적 판단을 중시하는 유형입니다.',
  recommendations: [
    { rank: 1, job_name: '향수 조향사', job_name_en: 'Perfumer', description: '세계적인 향수 브랜드에서 새로운 향기를 개발하는 전문가', face_reason: '넓은 이마와 섬세한 눈매는 높은 감각적 민감성과 창의력을 나타냅니다.', mbti_reason: '깊은 내면 세계와 예술적 감수성은 향기라는 보이지 않는 예술을 창조하는 데 최적입니다.', match_score: 94, skills: ['후각 민감성', '화학 지식', '창의력'], salary_range: '4,000~8,000만원' },
    { rank: 2, job_name: '게임 사운드 디자이너', job_name_en: 'Game Sound Designer', description: '게임 속 효과음과 배경 음악을 설계하고 구현하는 전문가', face_reason: '예리한 눈매와 균형 잡힌 턱선은 집중력과 분석력이 뛰어남을 보여줍니다.', mbti_reason: '독립적인 작업 스타일과 디테일에 대한 집착은 완벽한 사운드를 만들어내는 데 강점입니다.', match_score: 87, skills: ['음향 편집', 'DAW 활용', '게임 엔진'], salary_range: '3,500~6,000만원' },
    { rank: 3, job_name: '문화재 복원사', job_name_en: 'Art Conservator', description: '손상된 문화재와 예술 작품을 원래 상태로 복원하는 전문가', face_reason: '강한 턱선과 안정적인 얼굴형은 인내심과 끈기를 나타냅니다.', mbti_reason: '꼼꼼하고 체계적인 성격은 문화재를 정확하게 복원하는 데 이상적인 조합입니다.', match_score: 82, skills: ['미술사', '화학', '세밀한 수작업'], salary_range: '3,000~5,000만원' },
  ],
}

function JobDetailModal({ job, mbti, medalColor, onClose }) {
  if (!job) return null
  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="relative bg-white w-full sm:max-w-lg sm:rounded-2xl rounded-t-3xl max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-white border-b border-border-light p-4 flex justify-between items-center rounded-t-3xl">
          <span className="text-lg font-bold text-ink">{job.job_name}</span>
          <button onClick={onClose} className="p-1 text-ink-tertiary hover:text-ink"><X size={20} /></button>
        </div>
        <div className="p-5 space-y-5">
          {job.generated_image_url && (
            <img src={job.generated_image_url} alt={job.job_name} className="w-full aspect-[4/3] object-cover rounded-xl" />
          )}
          <div>
            <p className="text-sm text-ink-tertiary">{job.job_name_en}</p>
            <div className="flex items-center gap-3 mt-1">
              <span className="text-lg font-bold" style={{ color: medalColor }}>매칭률 {job.match_score}%</span>
              <span className="text-sm text-ink-secondary">연봉 {job.salary_range}</span>
            </div>
          </div>
          <p className="text-sm text-ink-secondary leading-relaxed">{job.description}</p>

          <div className="space-y-4">
            <div>
              <div className="flex items-center gap-2 mb-2"><PawPrint size={16} className="text-brand-amber" /><span className="text-sm font-semibold text-ink">관상이 말하는 이유</span></div>
              <p className="text-sm text-ink-secondary leading-relaxed">{job.face_reason}</p>
            </div>
            <div>
              <div className="flex items-center gap-2 mb-2"><Brain size={16} className="text-brand-amber" /><span className="text-sm font-semibold text-ink">{mbti}와 맞는 이유</span></div>
              <p className="text-sm text-ink-secondary leading-relaxed">{job.mbti_reason}</p>
            </div>
            <div>
              <div className="flex items-center gap-2 mb-2"><Wrench size={16} className="text-brand-amber" /><span className="text-sm font-semibold text-ink">필요한 스킬</span></div>
              <div className="flex flex-wrap gap-2">
                {job.skills.map(s => (
                  <span key={s} className="px-3 py-1 rounded-full bg-surface text-xs text-ink-secondary border border-border-light">{s}</span>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function ResultPage() {
  const navigate = useNavigate()
  const location = useLocation()
  const [selectedJob, setSelectedJob] = useState(null)

  const result = location.state?.result || DEMO_RESULT
  const error = location.state?.error

  const face = result?.face_features
  const jobs = result?.recommendations || []
  const mbti = result?.mbti || 'INTJ'
  const photoUrl = localStorage.getItem('photoDataUrl')

  const keywords = face ? [face.face_shape, face.animal_type].filter(Boolean) : []

  if (error) {
    return (
      <div className="min-h-screen bg-canvas flex flex-col items-center justify-center px-6 text-center">
        <p className="text-lg font-semibold text-ink mb-2">분석 실패</p>
        <p className="text-sm text-ink-secondary mb-6">{error}</p>
        <button onClick={() => navigate('/')} className="px-6 py-3 bg-ink text-ink-inverted rounded-xl font-medium">처음으로</button>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-canvas">
      {/* Hero Header */}
      <div className="border-b border-border-light px-5 pt-4 pb-6" style={{ paddingTop: 'max(16px, env(safe-area-inset-top))' }}>
        <button onClick={() => navigate('/')} className="p-1 text-ink-secondary hover:text-ink mb-4"><X size={22} /></button>
        <div className="flex items-center gap-4">
          {photoUrl && (
            <div className="w-14 h-14 rounded-full overflow-hidden border-2 border-border-strong flex-shrink-0">
              <img src={photoUrl} alt="" className="w-full h-full object-cover" />
            </div>
          )}
          <div>
            <h1 className="text-2xl font-bold text-ink">당신의 직업 DNA</h1>
            <span className="inline-block mt-1 px-2.5 py-0.5 rounded-lg bg-brand-amber-bg text-brand-amber-text text-xs font-bold">{mbti}</span>
          </div>
        </div>
        {keywords.length > 0 && (
          <div className="flex flex-wrap gap-2 mt-4">
            {keywords.map(kw => (
              <span key={kw} className="px-3 py-1 rounded-full bg-surface border border-border-light text-xs text-ink-secondary">{kw}</span>
            ))}
          </div>
        )}
      </div>

      {/* Animal Type */}
      {face?.animal_type && (
        <div className="mx-5 mt-4 p-4 bg-white rounded-2xl border border-border-light">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <PawPrint size={18} className="text-brand-amber" />
              <span className="text-base font-bold text-ink">당신의 동물상</span>
            </div>
            <span className="px-3 py-1 rounded-full bg-brand-amber-bg text-brand-amber-text text-sm font-bold">{face.animal_type}</span>
          </div>
          {face.animal_description && <p className="mt-3 text-sm text-ink-secondary leading-relaxed">{face.animal_description}</p>}
        </div>
      )}

      {/* Face Summary */}
      {face?.personality_summary && (
        <div className="mx-5 mt-3 p-4 bg-white rounded-2xl border border-border-light">
          <div className="flex items-center gap-2 mb-3">
            <Quote size={16} className="text-brand-amber" />
            <span className="text-base font-bold text-ink">관상 분석 요약</span>
          </div>
          <p className="text-sm text-ink-secondary leading-relaxed">{face.personality_summary}</p>
        </div>
      )}

      {/* Job Grid */}
      <div className="mx-5 mt-6 mb-4">
        <div className="flex items-center gap-2 mb-4">
          <Briefcase size={18} className="text-brand-amber" />
          <span className="text-base font-bold text-ink">추천 직업 TOP 3</span>
        </div>
        <div className="grid grid-cols-3 gap-3">
          {jobs.map((job, idx) => {
            const medalColor = MEDAL_COLORS[idx] || MEDAL_COLORS[2]
            const isFirst = idx === 0
            return (
              <button
                key={job.rank}
                onClick={() => setSelectedJob({ job, medalColor })}
                className={`text-left rounded-2xl overflow-hidden bg-white border ${isFirst ? 'border-2 border-gold' : 'border-border-light'} transition-transform active:scale-95`}
              >
                {/* Image */}
                <div className="relative aspect-[3/4] bg-surface">
                  {job.generated_image_url ? (
                    <img src={job.generated_image_url} alt={job.job_name} className="w-full h-full object-cover" />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-ink-tertiary text-2xl">💼</div>
                  )}
                  <span className="absolute top-2 left-2 px-2 py-0.5 rounded-lg text-[10px] font-bold text-white" style={{ backgroundColor: medalColor }}>
                    #{job.rank}
                  </span>
                </div>
                {/* Info */}
                <div className="p-2.5">
                  <p className={`font-bold text-ink truncate ${isFirst ? 'text-sm' : 'text-xs'}`}>{job.job_name}</p>
                  <p className="text-[10px] text-ink-tertiary truncate">{job.job_name_en}</p>
                  <p className="text-sm font-bold mt-1" style={{ color: medalColor }}>{job.match_score}%</p>
                  <p className="text-[11px] text-ink-secondary leading-snug mt-1 line-clamp-2">{job.description}</p>
                  <div className="flex flex-wrap gap-1 mt-2">
                    {job.skills.slice(0, 2).map(s => (
                      <span key={s} className="px-1.5 py-0.5 rounded bg-surface text-[9px] text-ink-tertiary border border-border-light">{s}</span>
                    ))}
                  </div>
                </div>
              </button>
            )
          })}
        </div>
      </div>

      {/* Bottom Actions */}
      <div className="px-5 py-6 border-t border-border-light mt-4">
        <p className="text-sm font-semibold text-ink text-center mb-4">결과 공유하기</p>
        <div className="flex justify-center gap-6 mb-6">
          {[
            { label: '카카오톡', bg: '#FEE500', color: '#3C1E1E', icon: '💬' },
            { label: '인스타그램', bg: '#E1306C', color: '#fff', icon: '📷' },
            { label: '페이스북', bg: '#1877F2', color: '#fff', icon: '👍' },
          ].map(s => (
            <button key={s.label} className="flex flex-col items-center gap-2">
              <div className="w-12 h-12 rounded-full flex items-center justify-center text-xl shadow-md" style={{ backgroundColor: s.bg, color: s.color }}>{s.icon}</div>
              <span className="text-[11px] text-ink-secondary">{s.label}</span>
            </button>
          ))}
        </div>
        <button
          onClick={() => { localStorage.removeItem('photoDataUrl'); localStorage.removeItem('returnTo'); navigate('/') }}
          className="w-full py-3 rounded-xl border border-border-light text-ink-secondary text-sm font-medium hover:bg-surface transition-colors"
        >
          다시 분석하기
        </button>
      </div>

      {/* Detail Modal */}
      {selectedJob && (
        <JobDetailModal
          job={selectedJob.job}
          mbti={mbti}
          medalColor={selectedJob.medalColor}
          onClose={() => setSelectedJob(null)}
        />
      )}
    </div>
  )
}
