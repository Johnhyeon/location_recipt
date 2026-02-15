# Project Context

## 프로젝트 개요
**ReceiptMap** - 결제 알림을 자동 캡처하여 위치 기반으로 지도에 시각화하는 모바일 앱.
사용자가 결제할 때마다 알림을 읽어 GPS 위치와 결합, 지도 위에 소비 내역을 핀으로 표시한다.
장기적으로 사용자 간 소비 장소를 선택적으로 공유하는 커뮤니티 기능으로 확장 예정.

**타겟**: Hashed Vibe Labs 지원용 프로젝트

## 기술 스택
- Language: TypeScript
- Framework: React Native (Expo, expo-dev-client)
- DB: PostgreSQL + PostGIS (Supabase)
- Auth: Supabase Auth (Email, Google OAuth)
- Map: react-native-maps + Mapbox
- State: Zustand
- Backend: Supabase (BaaS) + Edge Functions
- CI/CD: EAS Build + GitHub Actions
- 알림 캡처: Android NotificationListenerService (네이티브 모듈)

## 디렉토리 구조
```
├── app/                    # Expo Router 페이지
│   ├── (tabs)/             # 탭 네비게이션
│   │   ├── map.tsx         # 지도 뷰 (메인)
│   │   ├── list.tsx        # 리스트 뷰
│   │   └── settings.tsx    # 설정
│   ├── _layout.tsx         # 루트 레이아웃
│   └── auth.tsx            # 로그인/회원가입
├── components/             # 재사용 컴포넌트
├── hooks/                  # 커스텀 훅
├── lib/                    # 유틸리티, API 클라이언트
│   ├── supabase.ts         # Supabase 클라이언트
│   ├── notification.ts     # 알림 파싱 로직
│   └── location.ts         # 위치 서비스
├── stores/                 # Zustand 스토어
├── types/                  # TypeScript 타입 정의
├── android/                # Android 네이티브 코드
│   └── NotificationListener/  # NotificationListenerService
├── supabase/               # Supabase 설정
│   ├── migrations/         # DB 마이그레이션
│   └── functions/          # Edge Functions
├── plans/                  # 기획안
└── scripts/                # 자동화 스크립트
```

## 코딩 컨벤션
- 커밋 메시지: Conventional Commits (feat: / fix: / refactor: / chore:)
- 브랜치 전략: main ← feat/기능명, fix/버그명
- 테스트: 새 기능에는 반드시 유닛 테스트 포함
- 컴포넌트: 함수형 컴포넌트 + hooks 패턴
- 스타일: StyleSheet.create 사용 (inline 지양)
- import 순서: React → 외부 라이브러리 → 내부 모듈 → 타입
- 파일명: kebab-case (컴포넌트는 PascalCase.tsx)

## 빌드 & 실행
```bash
# 의존성 설치
npm install

# 개발 서버 실행 (Expo)
npx expo start

# Android 개발 빌드 (네이티브 모듈 포함)
npx expo run:android

# 테스트 실행
npm test

# Supabase 로컬 개발
npx supabase start
npx supabase db push

# EAS 빌드
eas build --platform android --profile preview
```

## 기획 출력 규칙
기획안 작성 시 반드시 아래 형식을 따를 것:
1. `plans/` 디렉토리에 `PLAN-{YYYYMMDD}-{feature-name}.md`로 저장
2. 각 태스크는 Codex가 독립적으로 실행할 수 있도록 분리
3. 태스크마다 아래 항목 필수 포함:
   - 파일: 수정/생성할 파일 경로
   - 설명: 구체적 구현 내용
   - 의존성: 선행 태스크 번호
   - 검증: 테스트 명령어 또는 확인 방법

## 주의사항
- Android 우선 개발 (iOS는 알림 접근 제한으로 Phase 3 이후)
- Supabase RLS(Row Level Security) 반드시 활성화
- 위치 정보는 민감 데이터 → 최소 수집 원칙, 사용자 동의 필수
- API 키/시크릿은 절대 코드에 하드코딩 금지 → .env + expo-constants
- 결제 알림 파싱은 정규식 기반, 토스/카카오뱅크/신한 등 주요 앱별 패턴 관리
