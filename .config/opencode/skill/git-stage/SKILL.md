---
name: git-stage
description: "Git Stage (dev/main) 운영 규칙"
---

# Git Stage

## Stage 구분

| Stage | 브랜치 | 용도 |
|-------|--------|------|
| Dev | `dev` | 개발 환경, 운영 환경의 레플리카 |
| Main | `main` | 실제 운영 환경 |

## 작업 흐름

```
이슈 생성 → 브랜치 생성 → 작업/커밋/Push → PR 생성 → Merge
```

## 브랜치 생성 기준

| 조건 | base 브랜치 |
|------|-------------|
| dev 브랜치가 있음 | `dev` |
| dev 브랜치가 없음 | `main` |
| 긴급 수정 (hotfix) | `main` |

## Stage별 규칙

**Dev**: 개발 완료된 코드만 PR로 merge, 검증 후 main으로 배포

**Main**: 배포 가능한 코드만 PR로 merge, **직접 push 금지** (hotfix 제외)

## Hotfix

**조건** (모두 충족 시에만):
- 정말 긴급한 상황 (서비스 장애, 보안 취약점)
- PR 프로세스를 거칠 시간이 없음
- 변경 범위가 명확하고 최소한

**프로세스**:
```bash
git checkout main && git pull
# 최소한의 수정 (버그 수정만, 새 기능 추가 금지)
git commit -m "fix: {긴급 버그 설명}"
git push origin main
```

**후속 조치** (24시간 내):
- 이슈에 매뉴얼 기록 (shell-command 스킬)
- dev에 역반영: `git checkout dev && git cherry-pick <hash> && git push`
- 사후 PR로 문서화

## 저장소 유형별 흐름

| 유형 | 흐름 |
|------|------|
| 프로젝트 (서비스, 인프라) | 이슈 → 브랜치 → PR → merge |
| 문서/아카이브 | 직접 commit → push |

## 확인 명령어

```bash
git branch --show-current    # 현재 브랜치
git branch -a | grep dev     # dev 존재 여부
```
