import { useEffect } from 'react'
import { Routes, Route, useNavigate, useLocation } from 'react-router-dom'
import HomePage from './pages/HomePage'
import PhotoPage from './pages/PhotoPage'
import MbtiPage from './pages/MbtiPage'
import AnalyzingPage from './pages/AnalyzingPage'
import ResultPage from './pages/ResultPage'

function MobileReturnGuard({ children }) {
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    // 모바일 카메라에서 복귀 시: 홈(/)으로 돌아갔는데 사진이 저장되어 있으면 /photo로 리다이렉트
    const returnTo = localStorage.getItem('returnTo')
    if (location.pathname === '/' && returnTo) {
      localStorage.removeItem('returnTo')
      navigate(returnTo, { replace: true })
    }
  }, [location.pathname, navigate])

  return children
}

export default function App() {
  return (
    <div className="min-h-screen bg-canvas">
      <MobileReturnGuard>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/photo" element={<PhotoPage />} />
          <Route path="/mbti" element={<MbtiPage />} />
          <Route path="/analyzing" element={<AnalyzingPage />} />
          <Route path="/result" element={<ResultPage />} />
        </Routes>
      </MobileReturnGuard>
    </div>
  )
}
