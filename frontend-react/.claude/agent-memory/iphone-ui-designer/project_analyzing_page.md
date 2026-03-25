---
name: AnalyzingPage Pentagon Oracle Design
description: 직감 앱 AI 분석 로딩 페이지의 오각형 오라클 디자인 - 노드 배치, 애니메이션, 구조 상세
type: project
---

## AnalyzingPage 디자인 시스템 (Pentagon Oracle)

### 레이아웃 구조
- Container: 320x320px 정사각형 상대 위치 영역
- 중심점: (160, 160)
- Pentagon 반지름: 124px (노드 중심까지)
- 노드 크기: 64x64px (배지 44x44px + 레이블)

### 5노드 좌표 (left, top — box 좌상단 기준)
- 0 천정(天庭): 각도 -90° → (132px, 약 36px) — 정상단
- 1 감찰관(監察官): 각도 -18° → (246px, 약 121px) — 우상
- 2 심판관(審辨官): 각도 54° → (208px, 약 256px) — 우하
- 3 출납관(出納官): 각도 126° → (68px, 약 256px) — 좌하
- 4 오행(五行): 각도 198° → (26px, 약 121px) — 좌상

### 노드 상태 3종
- pending: opacity 0.35, 회색 border, 한자 희미하게
- active: node-activate 입장 애니메이션 → node-pulse-active 지속, 골드 border 강조
- done: node-complete-shimmer 지속, 체크마크 표시, 골드 채색

### SVG 레이어
- 오각형 외곽선: strokeDasharray "4 3" 점선, 투명도 15%
- 방사선(스포크): 노드 활성화 시 stroke-dashoffset 트랜지션으로 그려짐
- glow-line 필터: 활성 스포크에 적용

### 중심 사진 원
- 크기: 104x104px (inset: CENTER±52)
- 헤일로: 8px 바깥 점선 링 animate-photo-halo (8s 회전)
- 글로우 링: animate-oracle-breathe (3.2s)
- border: 2.5px solid 골드 50%

### 애니메이션 목록 (index.css에 추가)
- oracle-breathe: 3.2s ease-in-out — 중심 글로우 링
- oracle-ring-1/2/3: 9s/13s/7s linear — 배경 동심원
- node-activate: 0.7s cubic-bezier(0.34,1.56,0.64,1) — 노드 진입
- node-pulse-active: 2s ease-in-out infinite — 활성 노드 박동
- node-complete-shimmer: 3s ease-in-out infinite — 완료 노드
- connector-draw / connector-flow: SVG 선 드로잉
- stage-desc-in: 0.5s — 설명 텍스트 교체 시
- photo-halo: 8s linear — 사진 헤일로 회전
- progress-glow: 2s — 프로그레스 바 글로우
- ticker-in: 0.35s — 퍼센트 숫자 업데이트

### 색상 토큰 사용
- 배경: var(--color-canvas) #FAFAF8
- 골드 액센트: var(--color-brand-amber) #B8860B
- 텍스트: var(--color-ink) #1C1917
- 보조 텍스트: var(--color-ink-tertiary) #A8A29E
- 진행바: 그라데이션 rgba(184,134,11,0.6) → #B8860B → #D4A017
