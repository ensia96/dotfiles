---
name: git-push
description: "Push 전 검토 체크리스트"
---

# Git Push

## Push 전 체크리스트

```
[ ] 모든 커밋 메시지가 한글인가? (type 제외)
[ ] 커밋 메시지 형식이 "{type}: {메시지}" 인가?
[ ] 민감 정보(토큰, 비밀번호)가 포함되지 않았는가?
[ ] 브랜치명이 "{issue}/{worker}/{YYYY-MM-DD}" 형식인가?
[ ] PR 생성 준비가 되었는가?
```

## 확인 명령어

```bash
# 커밋 메시지 확인
git log --oneline -10

# 변경 파일 확인
git diff origin/main...HEAD --name-only

# 브랜치명 확인
git branch --show-current
```

## Push 명령어

```bash
# 첫 push (upstream 설정)
git push -u origin $(git branch --show-current)

# 이후 push
git push
```

## 금지 사항

| 금지 | 이유 |
|------|------|
| `git push --force` | 히스토리 손실 위험 |
| `git push origin main` | main 직접 push 금지 (hotfix 제외) |
| 민감 정보 포함 커밋 push | 보안 위험 |

## Push 후

- PR 생성 (`github-pull-request` 스킬 참조)
- 또는 기존 PR에 커밋 추가됨
