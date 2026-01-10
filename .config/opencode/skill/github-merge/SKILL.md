---
name: github-merge
description: "GitHub PR Merge 규칙"
---

# GitHub Merge

## Merge 방식

| 방식 | 사용 | 이유 |
|------|------|------|
| **일반 merge** | 항상 | 커밋 이력 유지 |
| **squash merge** | 금지 | 이력 손실 |
| **rebase merge** | 금지 | 히스토리 변경 |

## Merge 명령어

```bash
# GitHub CLI로 merge (권장)
gh pr merge {PR번호} --merge

# 또는 GitHub 웹에서 "Create a merge commit" 선택
```

## 저장소 설정

squash merge 자체를 막으려면:

```bash
# GitHub 저장소 설정에서
# Settings → General → Pull Requests
# "Allow squash merging" 체크 해제
```

## Merge 전 체크리스트

```
[ ] PR 리뷰 완료
[ ] CI/CD 통과
[ ] 이슈 연결 확인
[ ] Merge 방식이 "Create a merge commit" 인지 확인
```

## Squash Merge 실수 복구

**이미 squash merge 했다면**:

1. Squash된 커밋을 revert하는 PR 생성
   ```bash
   git revert {squash-commit-hash}
   ```
2. Revert PR을 정상 merge
3. 원래 브랜치를 다시 정상 merge (squash 아님)

**주의**: 복구 과정도 히스토리에 남음. 처음부터 squash 안 하는 게 최선.
