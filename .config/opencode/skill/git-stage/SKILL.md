---
name: git-stage
description: "Git Stage (develop/main) 운영 규칙"
---

# Git Stage

## Stage 구분

| Stage | 브랜치 | 용도 |
|-------|--------|------|
| **Dev** | `develop` | 개발 환경, 운영 환경의 레플리카 |
| **Main** | `main` | 실제 운영 환경, 사용자에게 전달되는 서비스 |

## 작업 흐름

```
이슈 생성
    ↓
브랜치 생성 (main 또는 develop에서)
    ↓
작업 → 커밋 → Push
    ↓
PR 생성 → 리뷰 → Merge
```

## 어디서 브랜치를 생성할까?

| 조건 | base 브랜치 | 이유 |
|------|-------------|------|
| develop 브랜치가 있음 | `develop` | 개발 환경에서 먼저 검증 |
| develop 브랜치가 없음 | `main` | 단일 브랜치 운영 |
| 긴급 수정 (hotfix) | `main` | 운영 환경 직접 수정 |

## Develop Stage

- 개발 완료된 코드만 PR을 통해 merge
- 수정이 필요한 경우에만 fix 커밋을 통해 수정
- 검증 후 main으로 배포

## Main Stage

- 배포 가능한 코드만 PR을 통해 merge
- **main 직접 push 금지** (hotfix 제외)

## Hotfix (긴급 수정)

**Hotfix = fix 커밋을 main에 직접 push하는 프로세스**

| 일반 수정 | Hotfix |
|----------|--------|
| 브랜치 생성 → PR → merge | main에 직접 커밋 → push |
| 검토 후 반영 | 즉시 반영 |

```bash
# Hotfix 프로세스
git checkout main
git pull
# 수정 작업
git add .
git commit -m "fix: 긴급 버그 수정"
git push origin main
```

**주의**: Hotfix는 정말 긴급한 상황에서만 사용. 가능하면 PR 프로세스 준수.

## 저장소 유형별 흐름

| 유형 | 예시 | 흐름 |
|------|------|------|
| **프로젝트** | 서비스, 인프라, 라이브러리 | 이슈 → 브랜치 → PR → merge |
| **문서/아카이브** | 개인 노트, 표준 문서 | 직접 commit → push |

## 확인 명령어

```bash
# 현재 브랜치 확인
git branch --show-current

# develop 브랜치 존재 여부
git branch -a | grep develop

# 원격 브랜치 목록
git branch -r
```
