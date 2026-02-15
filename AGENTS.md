# Agents Guide

## 프로젝트 설명
<!-- TODO: 프로젝트 설명을 여기에 작성 -->

## 개발 환경 셋업
<!-- TODO: 프로젝트별 셋업 명령어 작성 -->
```bash
# 의존성 설치
# 환경변수 설정
# DB 마이그레이션
```

## 코딩 규칙
- 모든 함수에 docstring/JSDoc 작성
- 새 기능에는 반드시 유닛 테스트 포함
- 기존 테스트가 깨지지 않도록 확인
- 에러 핸들링을 명시적으로 구현

## 테스트 실행
<!-- TODO: 프로젝트별 테스트 명령어 작성 -->
```bash
# 전체 테스트
# 특정 파일 테스트
# 커버리지 확인
```

## PR 규칙
- PR 제목: `feat:` / `fix:` / `refactor:` 접두사 사용
- 변경사항 요약을 PR description에 포함
- 관련 Issue 번호 참조 (#번호)

## Review guidelines
- 보안 취약점 체크 (SQL injection, XSS, CSRF 등)
- 하드코딩된 시크릿 또는 API 키 없는지 확인
- 에러 핸들링이 적절한지 검증
- 불필요한 console.log / print 문 제거
- 타입 안정성 확인 (TypeScript의 경우 any 지양)

## 파일 구조 가이드
<!-- TODO: 새 파일 생성 시 참고할 구조 설명 -->
