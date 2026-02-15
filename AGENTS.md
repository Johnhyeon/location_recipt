# Agents Guide

## 프로젝트 설명
**ReceiptMap** - 결제 알림 + GPS 위치 기반 소비 내역 지도 시각화 앱.
Android NotificationListenerService로 결제 알림을 캡처하고, 현재 위치와 결합하여
지도 위에 소비 기록을 표시한다. Supabase를 BaaS로 사용하며, React Native (Expo) 기반.

## 개발 환경 셋업
```bash
# 의존성 설치
npm install

# Supabase 로컬 환경 시작
npx supabase start

# DB 마이그레이션 적용
npx supabase db push

# 환경변수 설정
cp .env.example .env.local
# EXPO_PUBLIC_SUPABASE_URL, EXPO_PUBLIC_SUPABASE_ANON_KEY,
# EXPO_PUBLIC_MAPBOX_TOKEN 설정

# Expo 개발 서버
npx expo start

# Android 네이티브 빌드 (NotificationListener 포함)
npx expo run:android
```

## 코딩 규칙
- TypeScript strict 모드 사용
- 모든 exported 함수에 JSDoc 작성
- 새 기능에는 반드시 유닛 테스트 포함
- 기존 테스트가 깨지지 않도록 확인
- 에러 핸들링을 명시적으로 구현
- `any` 타입 사용 금지 → 구체적 타입 또는 `unknown` 사용
- 컴포넌트 props는 별도 interface로 정의
- Supabase 쿼리는 lib/ 내 함수로 래핑하여 사용

## 테스트 실행
```bash
# 전체 테스트
npm test

# 특정 파일 테스트
npm test -- --testPathPattern=notification

# 커버리지 확인
npm test -- --coverage

# 타입 체크
npx tsc --noEmit
```

## PR 규칙
- PR 제목: `feat:` / `fix:` / `refactor:` 접두사 사용
- 변경사항 요약을 PR description에 포함
- 관련 Issue 번호 참조 (#번호)
- 스크린샷/영상 첨부 (UI 변경 시 필수)

## Review guidelines
- 보안 취약점 체크 (SQL injection, XSS, CSRF 등)
- 하드코딩된 시크릿 또는 API 키 없는지 확인
- 에러 핸들링이 적절한지 검증
- 불필요한 console.log 제거
- 타입 안정성 확인 (any 지양)
- Supabase RLS 정책이 적용되어 있는지 확인
- 위치 데이터 접근 시 사용자 권한 요청 로직 확인

## 파일 구조 가이드
```
새 페이지 추가 시:      app/(tabs)/새페이지.tsx
새 컴포넌트 추가 시:    components/ComponentName.tsx
새 훅 추가 시:          hooks/useHookName.ts
새 유틸리티 추가 시:    lib/utilName.ts
새 스토어 추가 시:      stores/storeNameStore.ts
새 타입 추가 시:        types/typeName.ts
DB 마이그레이션 추가 시: supabase/migrations/YYYYMMDDHHMMSS_description.sql
Edge Function 추가 시:  supabase/functions/function-name/index.ts
```

## 핵심 데이터 모델
```sql
-- receipts: 결제 내역
receipts (
  id uuid PK,
  user_id uuid FK → auth.users,
  amount integer NOT NULL,          -- 결제 금액 (원)
  merchant text NOT NULL,           -- 가맹점명
  category text,                    -- 카테고리
  latitude double precision,        -- 위도
  longitude double precision,       -- 경도
  address text,                     -- 역지오코딩 주소
  raw_notification text,            -- 원본 알림 텍스트
  source text DEFAULT 'notification', -- 입력 소스
  created_at timestamptz,           -- 결제 시각
  is_public boolean DEFAULT false   -- 커뮤니티 공개 여부
)
```
