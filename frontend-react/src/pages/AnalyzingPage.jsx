import { useState, useEffect, useRef, useMemo, useCallback } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'

function useIsMobile(breakpoint = 520) {
  const [isMobile, setIsMobile] = useState(() => window.innerWidth < breakpoint)
  useEffect(() => {
    const handler = () => setIsMobile(window.innerWidth < breakpoint)
    window.addEventListener('resize', handler)
    return () => window.removeEventListener('resize', handler)
  }, [breakpoint])
  return isMobile
}

// ── 5단계 관상 분석 노드 ──────────────────────────────────────
const STAGES = [
  {
    key: 'cheonjeong',
    hanja: '天庭',
    title: '천정',
    subtitle: '이마 · 초년운',
    term: '천정(天庭)이란?',
    termDesc: '이마의 가장 윗부분을 말해요. 관상학에서 "하늘의 기운을 받는 자리"라고 불립니다.',
    desc: '이마는 1세~30세까지의 초년운을 나타냅니다. 이마가 넓고 깨끗하면 어릴 때부터 총명하고 학업운이 좋은 상이에요. 반대로 이마에 흉터나 잔주름이 많으면 초년에 고생이 있을 수 있다고 봅니다.',
    emoji: '☽',
    cardPos: 'below',
  },
  {
    key: 'gamchal',
    hanja: '監察官',
    title: '감찰관',
    subtitle: '눈매 · 내면',
    term: '감찰관(監察官)이란?',
    termDesc: '눈을 뜻하는 관상학 용어예요. "마음을 감시하고 살피는 관리"라는 뜻입니다.',
    desc: '"눈은 마음의 창"이라는 말처럼, 눈의 맑기·빛·크기·눈꼬리 방향으로 성격과 대인관계를 읽어요. 흑백이 또렷한 눈은 판단력이 뛰어나고, 눈에 빛이 있으면 의지가 강한 사람이라고 해석합니다.',
    emoji: '◎',
    cardPos: 'left',
  },
  {
    key: 'simpan',
    hanja: '審辨官',
    title: '심판관',
    subtitle: '코 · 재물운',
    term: '심판관(審辨官)이란?',
    termDesc: '코를 가리키는 말이에요. "심사하고 분별하는 관리"라는 뜻으로, 재물운의 핵심입니다.',
    desc: '코는 재백궁(財帛宮)이라고도 불리며, 돈과 자존심을 상징해요. 콧대가 곧으면 성품이 바르고, 코끝(준두)이 풍만하면 재물을 잘 모으는 상이에요. 콧구멍이 보이지 않으면 돈을 아껴 쓰는 타입입니다.',
    emoji: '◇',
    cardPos: 'left',
  },
  {
    key: 'chulnap',
    hanja: '出納官',
    title: '출납관',
    subtitle: '입 · 식록',
    term: '출납관(出納官)이란?',
    termDesc: '입을 뜻해요. "들이고 내보내는 관리"라는 의미로, 먹고사는 복(식록)을 관장합니다.',
    desc: '입술이 두텁고 색이 좋으면 정이 많고 인복이 있는 상이에요. 입꼬리가 위로 올라가면 낙천적이고 사교적이며, 인중(코와 입 사이 홈)이 깊고 길면 생명력이 강하고 자녀운도 좋다고 봅니다.',
    emoji: '〜',
    cardPos: 'right',
  },
  {
    key: 'ohaeng',
    hanja: '五行',
    title: '오행',
    subtitle: 'MBTI 교차',
    term: '오행(五行)이란?',
    termDesc: '목(나무)·화(불)·토(흙)·금(쇠)·수(물), 세상 만물을 이루는 다섯 기운을 말해요.',
    desc: '동양 관상학은 얼굴형으로 오행 체질을 분류합니다. 여기에 서양 심리학의 MBTI 16가지 성격 유형을 교차 대조하면, 당신의 기질과 성격이 동시에 가리키는 "천직(天職)"을 찾아낼 수 있어요.',
    emoji: '✦',
    cardPos: 'right',
  },
]

const TOTAL_DURATION = 25000
const STAGE_DURATION = TOTAL_DURATION / STAGES.length

// ── Pentagon 좌표 계산 ────────────────────────────────────────
function getPentagonNodes(size) {
  const center = size / 2
  const r = size * 0.38
  const nodeSize = size * 0.24
  return STAGES.map((stage, i) => {
    const angleDeg = -90 + i * 72
    const angleRad = (angleDeg * Math.PI) / 180
    const cx = center + r * Math.cos(angleRad)
    const cy = center + r * Math.sin(angleRad)
    return {
      ...stage,
      cx,
      cy,
      left: cx - nodeSize / 2,
      top: cy - nodeSize / 2,
      nodeSize,
    }
  })
}

// SVG: 노드 중심들을 잇는 오각형 선 + 중심까지의 방사선
function getPentagonPath(nodes) {
  const points = nodes.map(n => `${n.cx},${n.cy}`).join(' ')
  return `M ${nodes[0].cx} ${nodes[0].cy} ` +
    nodes.slice(1).map(n => `L ${n.cx} ${n.cy}`).join(' ') +
    ' Z'
}

function getSpokePath(node) {
  return `M ${CENTER} ${CENTER} L ${node.cx} ${node.cy}`
}

// 각 선분의 길이 (stroke-dasharray용)
function lineLen(x1, y1, x2, y2) {
  return Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
}

export default function AnalyzingPage() {
  const navigate = useNavigate()
  const location = useLocation()

  const [currentStage, setCurrentStage] = useState(0)
  const [progress, setProgress] = useState(0)
  // 각 노드의 상태: 'pending' | 'active' | 'done'
  const [nodeStates, setNodeStates] = useState(STAGES.map(() => 'pending'))
  // 방사선 표시 여부 (노드 활성화 순서대로)
  const [spokesVisible, setSpokesVisible] = useState(STAGES.map(() => false))
  // 현재 활성 단계 설명 텍스트 key (re-mount animation용)
  const [descKey, setDescKey] = useState(0)

  const apiResultRef = useRef(null)
  const apiErrorRef = useRef(null)
  const animationDoneRef = useRef(false)
  const apiDoneRef = useRef(false)
  const hasNavigatedRef = useRef(false)

  const photoUrl = location.state?.photoDataUrl || localStorage.getItem('photoDataUrl')
  const mbti = location.state?.mbti
  const isMobile = useIsMobile()

  // 반응형 사이즈 (데스크탑은 크게)
  const PSIZE = isMobile ? 240 : 400
  const CENTER = PSIZE / 2
  const nodes = useMemo(() => getPentagonNodes(PSIZE), [PSIZE])

  function tryNavigate() {
    if (hasNavigatedRef.current || !animationDoneRef.current || !apiDoneRef.current) return
    hasNavigatedRef.current = true
    if (apiErrorRef.current) {
      navigate('/result', { state: { error: apiErrorRef.current }, replace: true })
    } else {
      navigate('/result', { state: { result: apiResultRef.current }, replace: true })
    }
  }

  // API 호출
  useEffect(() => {
    const controller = new AbortController()
    const photoDataUrl = localStorage.getItem('photoDataUrl')
    fetch('/api/analyze', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ photo: photoDataUrl, mbti }),
      signal: controller.signal,
    })
      .then(res => { if (!res.ok) throw new Error(`서버 오류: ${res.status}`); return res.json() })
      .then(data => { apiResultRef.current = data; apiDoneRef.current = true; tryNavigate() })
      .catch(err => { if (err.name === 'AbortError') return; apiErrorRef.current = err.message; apiDoneRef.current = true; tryNavigate() })
    return () => controller.abort()
  }, [])

  // 진행률 타이머
  useEffect(() => {
    const start = Date.now()
    const interval = setInterval(() => {
      const pct = Math.min(((Date.now() - start) / TOTAL_DURATION) * 100, 100)
      setProgress(pct)
      if (pct >= 100) {
        clearInterval(interval)
        animationDoneRef.current = true
        tryNavigate()
      }
    }, 50)
    return () => clearInterval(interval)
  }, [])

  // 단계 진행 + 노드 상태 전환
  useEffect(() => {
    // 0번 노드 즉시 활성화
    setNodeStates(prev => {
      const next = [...prev]
      next[0] = 'active'
      return next
    })
    setSpokesVisible(prev => { const n = [...prev]; n[0] = true; return n })

    const interval = setInterval(() => {
      setCurrentStage(prev => {
        const next = Math.min(prev + 1, STAGES.length - 1)
        if (next !== prev) {
          // 이전 노드 완료, 다음 노드 활성화
          setNodeStates(ns => {
            const updated = [...ns]
            updated[prev] = 'done'
            updated[next] = 'active'
            return updated
          })
          setSpokesVisible(sv => { const n = [...sv]; n[next] = true; return n })
          setDescKey(k => k + 1)
        }
        return next
      })
    }, STAGE_DURATION)

    return () => clearInterval(interval)
  }, [])

  const pentagonPath = useMemo(() => getPentagonPath(nodes), [nodes])

  return (
    <div
      style={{
        minHeight: '100dvh',
        backgroundColor: 'var(--color-canvas)',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        padding: '16px 12px 20px',
        overflowX: 'hidden',
      }}
    >
      {/* ── 상단 헤더 ── */}
      <div style={{ width: '100%', maxWidth: isMobile ? 400 : 860, marginBottom: isMobile ? 10 : 10 }}>
        <p style={{
          fontSize: isMobile ? 10 : 16,
          letterSpacing: '0.18em',
          textTransform: 'uppercase',
          color: 'var(--color-ink-tertiary)',
          textAlign: 'center',
          fontWeight: 500,
        }}>
          AI 관상 분석
        </p>
        <h2 style={{
          fontSize: isMobile ? 17 : 32,
          fontWeight: 700,
          color: 'var(--color-ink)',
          textAlign: 'center',
          marginTop: 2,
          letterSpacing: '-0.02em',
        }}>
          면상(面相)을 읽는 중
        </h2>
      </div>

      {/* ── 메인 영역: 모바일=세로, 데스크탑=가로 ── */}
      <div style={{
        display: 'flex',
        flexDirection: isMobile ? 'column' : 'row',
        alignItems: isMobile ? 'center' : 'flex-start',
        gap: isMobile ? 12 : 32,
        width: '100%',
        maxWidth: isMobile ? 400 : 860,
        marginTop: 8,
        minHeight: 0,
      }}>

      {/* ── 오각형 오라클 영역 ── */}
      <div
        style={{
          position: 'relative',
          width: PSIZE,
          height: PSIZE,
          flexShrink: 0,
        }}
      >
        {/* 배경 후광 레이어들 — 동심원 3개 */}
        <div
          className="animate-oracle-ring-3"
          style={{
            position: 'absolute',
            inset: 20,
            borderRadius: '50%',
            border: '1px dashed rgba(184,134,11,0.18)',
            pointerEvents: 'none',
          }}
        />
        <div
          className="animate-oracle-ring-2"
          style={{
            position: 'absolute',
            inset: 10,
            borderRadius: '50%',
            border: '1px solid rgba(184,134,11,0.12)',
            pointerEvents: 'none',
          }}
        />
        <div
          className="animate-oracle-ring-1"
          style={{
            position: 'absolute',
            inset: 0,
            borderRadius: '50%',
            border: '1.5px solid rgba(184,134,11,0.09)',
            pointerEvents: 'none',
          }}
        />

        {/* SVG: 오각형 윤곽선 + 방사선(스포크) */}
        <svg
          viewBox={`0 0 ${PSIZE} ${PSIZE}`}
          width={PSIZE}
          height={PSIZE}
          style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}
        >
          <defs>
            <filter id="glow-line">
              <feGaussianBlur stdDeviation="1.5" result="blur" />
              <feMerge>
                <feMergeNode in="blur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
            <radialGradient id="photo-vignette" cx="50%" cy="50%" r="50%">
              <stop offset="60%" stopColor="transparent" />
              <stop offset="100%" stopColor="rgba(250,250,248,0.7)" />
            </radialGradient>
          </defs>

          {/* 오각형 외곽선 */}
          <path
            d={pentagonPath}
            fill="none"
            stroke="rgba(184,134,11,0.15)"
            strokeWidth="1"
            strokeDasharray="4 3"
          />

          {/* 방사선(스포크) — 노드 활성화 시 순차 등장 */}
          {nodes.map((node, i) => {
            const len = lineLen(CENTER, CENTER, node.cx, node.cy)
            const isVisible = spokesVisible[i]
            return (
              <line
                key={node.key}
                x1={CENTER}
                y1={CENTER}
                x2={node.cx}
                y2={node.cy}
                stroke={
                  nodeStates[i] === 'done'
                    ? 'rgba(184,134,11,0.45)'
                    : nodeStates[i] === 'active'
                      ? 'rgba(184,134,11,0.7)'
                      : 'rgba(184,134,11,0.08)'
                }
                strokeWidth={nodeStates[i] === 'active' ? 1.5 : 1}
                strokeDasharray={isVisible ? `${len} ${len}` : `${len} ${len}`}
                strokeDashoffset={isVisible ? 0 : len}
                filter={nodeStates[i] === 'active' ? 'url(#glow-line)' : undefined}
                style={{
                  transition: isVisible
                    ? 'stroke-dashoffset 0.8s cubic-bezier(0.4,0,0.2,1), stroke 0.5s ease, stroke-width 0.3s ease'
                    : 'none',
                }}
              />
            )
          })}

          {/* 중심 사진 위 비네팅 */}
          <circle cx={CENTER} cy={CENTER} r={PSIZE * 0.17} fill="url(#photo-vignette)" />
        </svg>

        {/* ── 중심 사진 원 ── */}
        <div
          style={{
            position: 'absolute',
            left: CENTER - PSIZE * 0.16,
            top: CENTER - PSIZE * 0.16,
            width: PSIZE * 0.32,
            height: PSIZE * 0.32,
          }}
        >
          {/* 포토 헤일로 — 회전하는 점선 링 */}
          <div
            className="animate-photo-halo"
            style={{
              position: 'absolute',
              inset: -8,
              borderRadius: '50%',
              border: '1.5px dashed rgba(184,134,11,0.4)',
            }}
          />
          {/* 내부 글로우 링 */}
          <div
            className="animate-oracle-breathe"
            style={{
              position: 'absolute',
              inset: -3,
              borderRadius: '50%',
              border: '2px solid rgba(184,134,11,0.25)',
              boxShadow: '0 0 20px 4px rgba(184,134,11,0.12)',
            }}
          />
          {/* 사진 */}
          <div
            style={{
              position: 'absolute',
              inset: 0,
              borderRadius: '50%',
              overflow: 'hidden',
              border: '2.5px solid rgba(184,134,11,0.5)',
              backgroundColor: 'var(--color-surface)',
            }}
          >
            {photoUrl ? (
              <img
                src={photoUrl}
                alt="분석 중인 사진"
                style={{ width: '100%', height: '100%', objectFit: 'cover' }}
              />
            ) : (
              <div style={{
                width: '100%', height: '100%',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                fontSize: 32, color: 'var(--color-ink-tertiary)',
              }}>
                面
              </div>
            )}
          </div>
        </div>

        {/* ── 5개 노드 ── */}
        {nodes.map((node, i) => {
          const state = nodeStates[i]
          const isActive = state === 'active'
          const isDone = state === 'done'
          const isPending = state === 'pending'

          return (
            <div
              key={node.key}
              style={{
                position: 'absolute',
                left: node.left,
                top: node.top,
                width: node.nodeSize,
                height: node.nodeSize,
                display: 'flex',
                flexDirection: 'column',
                alignItems: 'center',
                justifyContent: 'center',
                cursor: 'default',
              }}
            >
              {/* 노드 원형 배지 */}
              <div
                className={
                  isActive ? 'animate-node-active' :
                  isDone   ? 'animate-node-complete' : ''
                }
                style={{
                  width: PSIZE * 0.15,
                  height: PSIZE * 0.15,
                  borderRadius: '50%',
                  display: 'flex',
                  flexDirection: 'column',
                  alignItems: 'center',
                  justifyContent: 'center',
                  gap: 0,
                  backgroundColor: isDone
                    ? 'rgba(184,134,11,0.12)'
                    : isActive
                      ? 'rgba(184,134,11,0.08)'
                      : 'rgba(168,162,158,0.06)',
                  border: isDone
                    ? '1.5px solid rgba(184,134,11,0.55)'
                    : isActive
                      ? '2px solid rgba(184,134,11,0.85)'
                      : '1.5px solid rgba(168,162,158,0.2)',
                  transition: 'background-color 0.4s ease, border-color 0.4s ease, opacity 0.4s ease',
                  opacity: isPending ? 0.35 : 1,
                  // 활성화 진입 애니메이션
                  animation: isActive
                    ? 'node-activate 0.7s cubic-bezier(0.34,1.56,0.64,1) both, node-pulse-active 2s ease-in-out 0.7s infinite'
                    : isDone
                      ? 'node-complete-shimmer 3s ease-in-out infinite'
                      : 'none',
                }}
              >
                {/* 완료: 체크 / 활성: 한자 / 대기: 한자 희미하게 */}
                {isDone ? (
                  <span style={{
                    fontSize: 14,
                    color: 'var(--color-brand-amber)',
                    fontWeight: 700,
                    lineHeight: 1,
                  }}>
                    ✓
                  </span>
                ) : (
                  <span style={{
                    fontSize: 10,
                    color: isActive ? 'var(--color-brand-amber)' : 'var(--color-ink-tertiary)',
                    fontWeight: 600,
                    letterSpacing: '0.02em',
                    lineHeight: 1,
                    transition: 'color 0.3s ease',
                  }}>
                    {node.hanja.length <= 2 ? node.hanja : node.emoji}
                  </span>
                )}
              </div>

              {/* 노드 레이블 */}
              <div style={{
                marginTop: 2,
                textAlign: 'center',
                lineHeight: 1.2,
              }}>
                <div style={{
                  fontSize: isMobile ? 9.5 : 14,
                  fontWeight: isActive ? 700 : 500,
                  color: isActive
                    ? 'var(--color-ink)'
                    : isDone
                      ? 'var(--color-brand-amber)'
                      : 'var(--color-ink-tertiary)',
                  letterSpacing: '0.01em',
                  transition: 'color 0.3s ease, font-weight 0.3s ease',
                }}>
                  {node.title}
                </div>
                <div style={{
                  fontSize: isMobile ? 8 : 12,
                  color: isActive ? 'var(--color-ink-tertiary)' : 'rgba(168,162,158,0.5)',
                  marginTop: 1,
                  transition: 'color 0.3s ease',
                }}>
                  {node.subtitle}
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* ── 현재 단계 설명 카드 ── */}
      <div
        key={descKey}
        className="animate-stage-desc-in"
        style={{
          flex: isMobile ? 'none' : 1,
          width: isMobile ? '100%' : undefined,
          minWidth: 0,
          padding: isMobile ? '12px 14px' : '24px 28px',
          borderRadius: 14,
          backgroundColor: '#1C1917',
          border: '1px solid rgba(184,134,11,0.3)',
          boxShadow: '0 2px 16px rgba(0,0,0,0.2)',
          overflow: 'hidden',
          maxHeight: isMobile ? undefined : PSIZE + 20,
        }}
      >
        {/* 카드 헤더 */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: isMobile ? 8 : 12 }}>
          <div style={{
            width: isMobile ? 26 : 36,
            height: isMobile ? 26 : 36,
            borderRadius: '50%',
            backgroundColor: 'rgba(184,134,11,0.2)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: isMobile ? 11 : 16,
            fontWeight: 700,
            color: '#D4A017',
            flexShrink: 0,
          }}>
            {STAGES[currentStage].hanja.slice(0, 1)}
          </div>
          <div style={{ minWidth: 0 }}>
            <div style={{ fontSize: isMobile ? 14 : 20, fontWeight: 700, color: '#FFFFFF', lineHeight: 1.2 }}>
              {STAGES[currentStage].title}
              <span style={{ fontSize: isMobile ? 11 : 16, fontWeight: 500, color: 'rgba(255,255,255,0.5)', marginLeft: 6 }}>
                {STAGES[currentStage].subtitle}
              </span>
            </div>
          </div>
        </div>
        {/* 구분선 */}
        <div style={{ width: 24, height: 1, backgroundColor: 'rgba(184,134,11,0.4)', marginBottom: isMobile ? 8 : 12 }} />
        {/* 용어 설명 */}
        <div style={{
          backgroundColor: 'rgba(184,134,11,0.12)',
          borderRadius: 8,
          padding: isMobile ? '8px 10px' : '12px 16px',
          marginBottom: isMobile ? 8 : 12,
        }}>
          <p style={{
            fontSize: isMobile ? 12 : 16,
            fontWeight: 700,
            color: '#D4A017',
            marginBottom: 4,
            lineHeight: 1.3,
          }}>
            {STAGES[currentStage].term}
          </p>
          <p style={{
            fontSize: isMobile ? 11.5 : 15,
            lineHeight: 1.55,
            color: 'rgba(255,255,255,0.7)',
            wordBreak: 'keep-all',
          }}>
            {STAGES[currentStage].termDesc}
          </p>
        </div>
        {/* 설명 본문 */}
        <p style={{
          fontSize: isMobile ? 12 : 16,
          lineHeight: isMobile ? 1.75 : 1.7,
          color: 'rgba(255,255,255,0.85)',
          wordBreak: 'keep-all',
        }}>
          {STAGES[currentStage].desc}
        </p>
      </div>

      </div>{/* ── /메인 영역 flex 닫기 ── */}

      {/* ── 진행률 바 ── */}
      <div style={{ width: '100%', maxWidth: isMobile ? 400 : 860, marginTop: 16 }}>
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'baseline',
          marginBottom: 8,
        }}>
          <span style={{
            fontSize: 11,
            color: 'var(--color-ink-tertiary)',
            letterSpacing: '0.05em',
          }}>
            분석 진행률
          </span>
          <span
            key={`pct-${Math.floor(progress / 5)}`}
            className="animate-ticker-in"
            style={{
              fontSize: 13,
              fontWeight: 700,
              color: 'var(--color-brand-amber)',
              fontVariantNumeric: 'tabular-nums',
              letterSpacing: '-0.01em',
            }}
          >
            {Math.round(progress)}%
          </span>
        </div>

        {/* 트랙 */}
        <div style={{
          width: '100%',
          height: 3,
          backgroundColor: 'rgba(168,162,158,0.15)',
          borderRadius: 2,
          overflow: 'hidden',
        }}>
          <div
            className="animate-progress-glow"
            style={{
              height: '100%',
              width: `${progress}%`,
              background: 'linear-gradient(90deg, rgba(184,134,11,0.6) 0%, #B8860B 60%, #D4A017 100%)',
              borderRadius: 2,
              transition: 'width 0.1s linear',
            }}
          />
        </div>

        {/* 단계 인디케이터 도트 */}
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          marginTop: 8,
          paddingLeft: 1,
          paddingRight: 1,
        }}>
          {STAGES.map((_, i) => (
            <div
              key={i}
              style={{
                width: 4,
                height: 4,
                borderRadius: '50%',
                backgroundColor: nodeStates[i] === 'done'
                  ? 'var(--color-brand-amber)'
                  : nodeStates[i] === 'active'
                    ? 'rgba(184,134,11,0.6)'
                    : 'rgba(168,162,158,0.2)',
                transition: 'background-color 0.4s ease',
              }}
            />
          ))}
        </div>
      </div>

      {/* ── 하단 안내 ── */}
      <div style={{
        marginTop: 16,
        width: '100%',
        maxWidth: isMobile ? 400 : 860,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 8,
        padding: '10px 16px',
        borderRadius: 12,
        backgroundColor: 'rgba(184,134,11,0.05)',
        border: '1px solid rgba(184,134,11,0.12)',
      }}>
        <div style={{
          width: 5,
          height: 5,
          borderRadius: '50%',
          backgroundColor: 'var(--color-brand-amber)',
          flexShrink: 0,
          animation: 'oracle-breathe 1.8s ease-in-out infinite',
        }} />
        <span style={{
          fontSize: 11.5,
          color: 'rgba(184,134,11,0.85)',
          fontWeight: 500,
          letterSpacing: '0.01em',
        }}>
          분석 완료 시 자동으로 결과 페이지로 이동합니다
        </span>
      </div>
    </div>
  )
}
