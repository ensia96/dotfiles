---
name: git-stage
description: "Git Stage (dev/main) 운영 규칙"
---

# Git Stage

## Stage 구분

| Stage | 브랜치 | 용도 |
|-------|--------|------|
| **Dev** | `dev` | 개발 환경, 운영 환경의 레플리카 |
| **Main** | `main` | 실제 운영 환경, 사용자에게 전달되는 서비스 |

---

## 작업 흐름

```
이슈 생성
    ↓
브랜치 생성 (main 또는 dev에서)
    ↓
작업 → 커밋 → Push
    ↓
PR 생성 → 리뷰 → Merge
```

---

## 어디서 브랜치를 생성할까?

| 조건 | base 브랜치 | 이유 |
|------|-------------|------|
| dev 브랜치가 있음 | `dev` | 개발 환경에서 먼저 검증 |
| dev 브랜치가 없음 | `main` | 단일 브랜치 운영 |
| 긴급 수정 (hotfix) | `main` | 운영 환경 직접 수정 |

---

## Dev Stage

- 개발 완료된 코드만 PR을 통해 merge
- 수정이 필요한 경우에만 fix 커밋을 통해 수정
- 검증 후 main으로 배포

---

## Main Stage

- 배포 가능한 코드만 PR을 통해 merge
- **main 직접 push 금지** (hotfix 제외)

---

## Hotfix (긴급 수정)

**Hotfix = 스테이징 정책의 예외적 붕괴**

정상 프로세스를 우회하여 main에 직접 반영하는 것이므로, 엄격한 조건과 후속 조치가 필요하다.

### 조건 (모두 충족 시에만)

```
[ ] 정말 긴급한 상황인가? (서비스 장애, 보안 취약점 등)
[ ] PR 프로세스를 거칠 시간이 없는가?
[ ] 변경 범위가 명확하고 최소한인가?
```

### 프로세스

```bash
# 1. main에서 작업
git checkout main
git pull

# 2. 최소한의 수정
# (새 기능 추가 금지, 버그 수정만)

# 3. 커밋
git add .
git commit -m "fix: {긴급 버그 설명}"

# 4. Push
git push origin main
```

### 후속 조치 (CRITICAL)

| 조치 | 시점 | 설명 |
|------|------|------|
| **매뉴얼 기록** | 즉시 | shell-command 스킬에 따라 이슈에 기록 |
| **dev 역반영** | 24시간 내 | main 변경사항을 dev에 cherry-pick 또는 merge |
| **사후 PR** | 24시간 내 | hotfix 내용 문서화 (있었던 일, 원인, 조치) |

### dev 역반영 방법

```bash
# Option 1: Cherry-pick (권장)
git checkout dev
git cherry-pick <hotfix-commit-hash>
git push origin dev

# Option 2: main → dev merge
git checkout dev
git merge main
git push origin dev
```

### 금지 사항

| 금지 | 이유 |
|------|------|
| hotfix에서 새 기능 추가 | 스테이징 우회 목적 변질 |
| 후속 조치 없이 방치 | dev/main 불일치 발생 |
| 긴급하지 않은데 hotfix 사용 | 프로세스 무력화 |

---

## 저장소 유형별 흐름

| 유형 | 예시 | 흐름 |
|------|------|------|
| **프로젝트** | 서비스, 인프라, 라이브러리 | 이슈 → 브랜치 → PR → merge |
| **문서/아카이브** | 개인 노트, 표준 문서 | 직접 commit → push |

---

## 확인 명령어

```bash
# 현재 브랜치 확인
git branch --show-current

# dev 브랜치 존재 여부
git branch -a | grep dev

# 원격 브랜치 목록
git branch -r
```
