import { useNavigate } from "react-router-dom"
import { motion } from "framer-motion"
import { ArrowRight } from "lucide-react"

const ROW1 = ['/images/face-01.jpg', '/images/face-02.jpg', '/images/face-03.jpg']
const ROW2 = ['/images/face-04.jpg', '/images/face-05.jpg', '/images/face-06.jpg']
const ROW3 = ['/images/face-07.jpg', '/images/face-08.jpg', '/images/face-09.jpg']

const GAP = 4

function PhotoRow({ photos, startIndex = 0 }) {
  return (
    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: `${GAP}px` }}>
      {photos.map((src, i) => (
        <motion.div
          key={src}
          className="relative overflow-hidden"
          style={{ aspectRatio: '3/4', borderRadius: '10px' }}
          initial={{ opacity: 0, scale: 0.97 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.45, delay: 0.1 + (startIndex + i) * 0.05 }}
        >
          <img
            src={src}
            alt=""
            className="absolute inset-0 w-full h-full object-cover"
            loading={startIndex === 0 ? 'eager' : 'lazy'}
          />
        </motion.div>
      ))}
    </div>
  )
}

export default function HomePage() {
  const navigate = useNavigate()

  return (
    <div className="min-h-screen bg-[#FAFAF8]">

      {/* 네비게이션 */}
      <nav className="flex items-center justify-center gap-2 px-5 py-3 border-b border-[#E7E5E4]">
        <span className="text-xl font-extrabold text-[#1C1917]" style={{ letterSpacing: '-0.5px' }}>직감</span>
        <span className="text-[11px] text-[#A8A29E] font-medium">職感</span>
        <span className="text-[#D6D3D1] text-[10px]">|</span>
        <span className="text-[11px] text-[#A8A29E]">얼굴과 성격이 말해주는 나만의 직업 적성</span>
      </nav>

      {/* 그리드 + 타이틀 인터럽션 */}
      <div style={{ padding: '0 12px' }}>

        {/* Row 1 */}
        <motion.div
          style={{ paddingTop: '12px' }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5 }}
        >
          <PhotoRow photos={ROW1} startIndex={0} />
        </motion.div>

        {/* 타이틀 Strip */}
        <motion.div
          style={{
            position: 'relative',
            backgroundColor: '#F7F5F0',
            padding: '20px 16px 18px 16px',
            marginTop: `${GAP}px`,
            marginBottom: `${GAP}px`,
            borderRadius: '10px',
            overflow: 'hidden',
          }}
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, delay: 0.25 }}
        >
          <div style={{ width: '24px', height: '1.5px', backgroundColor: '#B8860B', marginBottom: '10px' }} />

          <span style={{
            display: 'block',
            fontSize: '10px',
            fontWeight: 600,
            letterSpacing: '1.8px',
            color: '#B8860B',
            marginBottom: '8px',
          }}>
            관상 × MBTI
          </span>

          <div className="flex items-center justify-between gap-3">
            <h1 style={{
              fontSize: '24px',
              fontWeight: 900,
              lineHeight: 1,
              letterSpacing: '-1.2px',
              color: '#1C1917',
              whiteSpace: 'nowrap',
            }}>
              관상으로 찾는 <span style={{ color: '#B8860B' }}>나의 직업 DNA</span>
            </h1>
            <motion.button
              onClick={() => navigate("/photo")}
              whileTap={{ scale: 0.95 }}
              className="flex-shrink-0 flex items-center justify-center bg-[#B8860B] text-white text-[13px] font-semibold py-5 rounded-full cursor-pointer border-none"
              style={{ width: '180px' }}
            >
              Start
            </motion.button>
          </div>


          {/* 한자 워터마크 */}
          <span style={{
            position: 'absolute',
            right: '12px',
            bottom: '10px',
            fontSize: '56px',
            fontWeight: 900,
            color: 'rgba(184, 134, 11, 0.07)',
            lineHeight: 1,
            userSelect: 'none',
            pointerEvents: 'none',
          }}>
            職
          </span>
        </motion.div>

        {/* Row 2 */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.3 }}
        >
          <PhotoRow photos={ROW2} startIndex={3} />
        </motion.div>

        {/* Row 3 */}
        <motion.div
          style={{ marginTop: `${GAP}px` }}
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.5, delay: 0.38 }}
        >
          <PhotoRow photos={ROW3} startIndex={6} />
        </motion.div>
      </div>

      <div style={{ height: '12px' }} />

    </div>
  )
}
