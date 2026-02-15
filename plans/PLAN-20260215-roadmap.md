# ReceiptMap 전체 구현 로드맵

> 결제 알림 + GPS 위치 기반 소비 내역 지도 시각화 앱
> 작성일: 2026-02-15

---

## Phase 1: 프로젝트 초기 셋업 (Day 1-2)

### Task 1.1: Expo 프로젝트 생성 및 기본 구조 설정
- **파일**: `package.json`, `app.json`, `tsconfig.json`, `app/_layout.tsx`, `app/(tabs)/_layout.tsx`
- **설명**:
  - `npx create-expo-app@latest --template tabs` 기반 프로젝트 생성
  - TypeScript strict 모드 설정
  - Expo Router 탭 네비게이션 구조 설정 (Map, List, Settings 3개 탭)
  - 기본 의존성 설치: react-native-maps, zustand, dayjs
- **의존성**: 없음
- **검증**: `npx expo start` 실행 후 3개 탭 전환 확인

### Task 1.2: Supabase 프로젝트 연동 및 DB 스키마 생성
- **파일**: `lib/supabase.ts`, `supabase/migrations/00001_create_receipts.sql`, `.env.example`
- **설명**:
  - Supabase 클라이언트 초기화 (`@supabase/supabase-js`)
  - receipts 테이블 생성 마이그레이션 작성
  - PostGIS 확장 활성화
  - RLS 정책 설정: 본인 데이터만 CRUD 가능
  - 환경변수 템플릿 작성
- **의존성**: Task 1.1
- **검증**: `npx supabase db push` 성공, Supabase 대시보드에서 테이블 확인

### Task 1.3: 인증 구현 (이메일 + Google OAuth)
- **파일**: `app/auth.tsx`, `lib/supabase.ts`, `stores/authStore.ts`, `app/_layout.tsx`
- **설명**:
  - Supabase Auth를 이용한 이메일/비밀번호 로그인
  - Google OAuth 로그인 (expo-auth-session)
  - 인증 상태 Zustand 스토어 관리
  - 미인증 시 auth 화면으로 리다이렉트
- **의존성**: Task 1.2
- **검증**: 회원가입 → 로그인 → 탭 화면 진입 → 로그아웃 플로우 테스트

---

## Phase 2: 핵심 기능 - 알림 캡처 & 위치 태깅 (Day 3-7)

### Task 2.1: Android NotificationListenerService 구현
- **파일**: `android/app/src/main/java/.../NotificationListener.java`, `android/app/src/main/AndroidManifest.xml`
- **설명**:
  - NotificationListenerService 상속 클래스 작성
  - 결제 관련 앱 패키지 필터링 (토스, 카카오뱅크, 신한 등)
  - 알림 텍스트를 React Native로 전달하는 Native Module 브릿지
  - 알림 접근 권한 요청 UI
- **의존성**: Task 1.1
- **검증**: 토스 결제 알림 수신 시 JS 콘솔에 알림 텍스트 출력 확인

### Task 2.2: 결제 알림 파싱 엔진
- **파일**: `lib/notification.ts`, `lib/__tests__/notification.test.ts`
- **설명**:
  - 주요 금융앱별 알림 텍스트 정규식 패턴 정의
    - 토스: "토스 | 5,000원 결제 | 스타벅스 강남점"
    - 카카오뱅크: "카카오뱅크 10,000원 결제 CU편의점"
    - 신한: "[신한카드] 15,000원 승인 맥도날드"
  - 파싱 결과: `{ amount: number, merchant: string, timestamp: Date }`
  - 파싱 실패 시 raw 텍스트 저장 + 수동 입력 유도
- **의존성**: Task 2.1
- **검증**: `npm test -- notification` → 금융앱별 파싱 테스트 통과

### Task 2.3: GPS 위치 서비스
- **파일**: `lib/location.ts`, `hooks/useLocation.ts`
- **설명**:
  - expo-location으로 현재 위치 가져오기
  - 백그라운드 위치 추적 (결제 시점 위치 정확도 향상)
  - 위치 권한 요청 플로우
  - 역지오코딩 (좌표 → 주소 변환)
- **의존성**: Task 1.1
- **검증**: 앱에서 현재 위치 좌표 + 주소 표시 확인

### Task 2.4: 결제 내역 저장 파이프라인
- **파일**: `lib/receipt.ts`, `stores/receiptStore.ts`, `hooks/useReceipts.ts`
- **설명**:
  - 알림 수신 → 파싱 → 위치 결합 → Supabase 저장 전체 파이프라인
  - 오프라인 시 로컬 큐에 저장 → 온라인 복귀 시 sync
  - Zustand 스토어로 로컬 상태 관리
  - Supabase 실시간 구독으로 다른 기기 동기화
- **의존성**: Task 2.2, Task 2.3, Task 1.2
- **검증**: 결제 알림 발생 → DB에 위치 포함 레코드 저장 확인

---

## Phase 3: 지도 시각화 (Day 8-12)

### Task 3.1: 지도 뷰 메인 화면
- **파일**: `app/(tabs)/map.tsx`, `components/ReceiptMapView.tsx`
- **설명**:
  - react-native-maps 기반 전체 화면 지도
  - 사용자의 결제 내역을 마커(핀)로 표시
  - 현재 위치 표시 + 내 위치로 이동 버튼
  - 마커 클러스터링 (가까운 핀 그룹화)
- **의존성**: Task 2.4
- **검증**: 지도에 저장된 결제 내역 핀이 정확한 위치에 표시되는지 확인

### Task 3.2: 결제 상세 바텀시트
- **파일**: `components/ReceiptBottomSheet.tsx`, `components/ReceiptCard.tsx`
- **설명**:
  - 지도 마커 탭 시 바텀시트 올라옴
  - 가맹점명, 금액, 시간, 주소 표시
  - 수정/삭제 기능
  - 바텀시트 라이브러리: @gorhom/bottom-sheet
- **의존성**: Task 3.1
- **검증**: 마커 탭 → 바텀시트 표시 → 정보 정확성 확인

### Task 3.3: 리스트 뷰
- **파일**: `app/(tabs)/list.tsx`, `components/ReceiptListItem.tsx`
- **설명**:
  - 날짜별 그룹화된 결제 내역 리스트
  - 무한 스크롤 (FlatList + 페이지네이션)
  - 리스트 아이템 탭 시 지도 뷰로 전환 + 해당 위치 포커스
  - 당겨서 새로고침
- **의존성**: Task 2.4
- **검증**: 결제 내역이 날짜순으로 정렬되어 표시, 스크롤/새로고침 동작 확인

### Task 3.4: 필터링 및 검색
- **파일**: `components/FilterBar.tsx`, `hooks/useReceiptFilter.ts`
- **설명**:
  - 날짜 범위 필터 (오늘, 이번 주, 이번 달, 커스텀)
  - 금액 범위 필터
  - 가맹점명 텍스트 검색
  - 필터 상태를 Zustand로 관리, 지도/리스트 뷰 모두 적용
- **의존성**: Task 3.1, Task 3.3
- **검증**: 필터 적용 시 지도 핀과 리스트 모두 필터링되는지 확인

---

## Phase 4: 사용자 경험 개선 (Day 13-16)

### Task 4.1: 수동 입력 기능
- **파일**: `app/add-receipt.tsx`, `components/AddReceiptForm.tsx`
- **설명**:
  - 수동으로 결제 내역 추가하는 폼
  - 금액, 가맹점명, 위치(현재 위치 or 지도에서 선택) 입력
  - 알림 파싱 실패 시 수동 입력으로 유도
- **의존성**: Task 2.4
- **검증**: 수동 입력 → 저장 → 지도/리스트에 표시 확인

### Task 4.2: 설정 화면
- **파일**: `app/(tabs)/settings.tsx`
- **설명**:
  - 알림 접근 권한 상태 표시 및 설정 이동
  - 위치 권한 상태 표시
  - 알림 캡처 대상 앱 선택
  - 로그아웃
  - 계정 삭제
  - 앱 버전 정보
- **의존성**: Task 1.3, Task 2.1
- **검증**: 각 설정 항목 동작 확인

### Task 4.3: 온보딩 플로우
- **파일**: `app/onboarding.tsx`, `components/OnboardingStep.tsx`
- **설명**:
  - 첫 실행 시 앱 소개 (3단계)
  - 알림 접근 권한 요청
  - 위치 권한 요청
  - 완료 후 메인 화면으로 이동
- **의존성**: Task 2.1, Task 2.3
- **검증**: 첫 실행 시 온보딩 표시 → 권한 설정 → 메인 화면 진입

---

## Phase 5: 커뮤니티 기능 (Day 17-24)

### Task 5.1: 공개 설정 및 프로필
- **파일**: `supabase/migrations/00002_add_profiles.sql`, `app/profile.tsx`, `stores/profileStore.ts`
- **설명**:
  - profiles 테이블 생성 (닉네임, 아바타, 공개 범위 설정)
  - 결제 내역별 공개/비공개 토글
  - 공개 시 표시 정보 선택 (가맹점명만 / 금액 포함 / 전체)
- **의존성**: Task 1.3
- **검증**: 공개 설정 변경 → 다른 계정에서 공개된 내역만 보이는지 확인

### Task 5.2: 주변 인기 장소 히트맵
- **파일**: `components/HeatmapLayer.tsx`, `supabase/functions/popular-places/index.ts`
- **설명**:
  - 공개된 결제 내역 기반 히트맵 레이어
  - PostGIS ST_ClusterDBSCAN으로 인기 장소 클러스터링
  - Edge Function으로 집계 데이터 제공 (개인정보 비식별화)
  - 시간대별/카테고리별 필터
- **의존성**: Task 5.1, Task 3.1
- **검증**: 지도에 히트맵 레이어 토글 → 인기 장소 표시 확인

### Task 5.3: 소셜 피드
- **파일**: `app/(tabs)/feed.tsx`, `components/FeedCard.tsx`, `supabase/migrations/00003_add_follows.sql`
- **설명**:
  - 팔로우한 사용자의 공개 결제 내역 피드
  - 사용자 검색 및 팔로우/언팔로우
  - 피드 카드: 닉네임 + 가맹점 + 위치 (선택적 금액)
  - Supabase Realtime으로 실시간 피드 업데이트
- **의존성**: Task 5.1
- **검증**: 팔로우 → 상대 공개 내역 피드에 표시, 비공개 내역 미표시 확인

---

## Phase 6: 고도화 & 사업화 준비 (Day 25-30)

### Task 6.1: 소비 통계 대시보드
- **파일**: `app/stats.tsx`, `components/SpendingChart.tsx`
- **설명**:
  - 월별/주별 소비 금액 차트
  - 카테고리별 소비 비율 파이 차트
  - 자주 가는 장소 TOP 5
  - react-native-chart-kit 또는 victory-native 사용
- **의존성**: Task 2.4
- **검증**: 통계 화면에서 차트 정상 렌더링 + 데이터 정합성 확인

### Task 6.2: 카테고리 자동 분류
- **파일**: `lib/categorizer.ts`, `lib/__tests__/categorizer.test.ts`
- **설명**:
  - 가맹점명 기반 카테고리 자동 분류 (식비, 교통, 쇼핑 등)
  - 키워드 매칭 + 사용자 학습 데이터 반영
  - 분류 실패 시 사용자에게 카테고리 선택 요청
- **의존성**: Task 2.2
- **검증**: 가맹점명 입력 → 올바른 카테고리 분류 테스트

### Task 6.3: 가게 프로필 페이지 (사업화 기반)
- **파일**: `app/merchant/[id].tsx`, `supabase/migrations/00004_add_merchants.sql`
- **설명**:
  - 가맹점별 프로필 페이지
  - 방문자 수, 인기도 통계 (비식별화)
  - 향후 광고/프로모션 연동 기반
- **의존성**: Task 5.2
- **검증**: 가맹점 페이지 접근 → 통계 표시 확인

### Task 6.4: 앱 스토어 배포 준비
- **파일**: `app.json`, `eas.json`, `.github/workflows/build.yml`
- **설명**:
  - EAS Build production 프로필 설정
  - 앱 아이콘, 스플래시 스크린 설정
  - Google Play Store 메타데이터 준비
  - GitHub Actions CI/CD 파이프라인
- **의존성**: Phase 4 완료
- **검증**: `eas build --platform android --profile production` 성공

---

## 마일스톤 요약

| Phase | 기간 | 핵심 산출물 | MVP 포함 |
|-------|------|-------------|----------|
| 1 | Day 1-2 | 프로젝트 셋업, 인증 | Yes |
| 2 | Day 3-7 | 알림 캡처, 위치 태깅 | Yes |
| 3 | Day 8-12 | 지도/리스트 시각화 | Yes |
| 4 | Day 13-16 | 수동 입력, 설정, 온보딩 | Yes |
| 5 | Day 17-24 | 커뮤니티, 피드, 히트맵 | No |
| 6 | Day 25-30 | 통계, 자동분류, 배포 | No |

**MVP = Phase 1~4 (약 16일)**
