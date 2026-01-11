---
name: github-pull-request
description: "GitHub Pull Request 생성 규칙"
---

# GitHub Pull Request

## 형식

### For dev (작업 PR)
```
[#{issue number}] {worker} ({YYYY-MM-DD})
```

### For release (배포 PR)
```
[배포] #{...PR numbers} ({YYYY-MM-DD})
```

## 예시

```
[#107] ensia96 (2026-01-10)
[#108] ensia96 (2026-01-11)
[배포] #1~#4 (2026-01-15)
```

## 생성 명령어

```bash
gh pr create \
  --title "[#107] ensia96 (2026-01-10)" \
  --assignee ensia96 \
  --body "Closes #107

## Summary
- 변경사항 요약"
```

## 필수 항목 (BLOCKING)

PR 생성 전 반드시 확인:

- [ ] **제목 양식**: `[#{이슈번호}] {작업자} ({날짜})`
- [ ] **어사이니 지정**: `--assignee {작업자}`
- [ ] **이슈 연결**: 아래 방법 중 하나
  - `gh issue develop`으로 브랜치 생성 (자동 연결)
  - 본문에 `Closes #` 포함
- [ ] **변경사항 요약**
- [ ] **매뉴얼 조작 기록** (있는 경우)

## 이슈 연결 키워드

| 키워드 | 용도 | 이슈 상태 |
|--------|------|----------|
| `Closes #` | 이슈 완전 해결 (마지막 PR) | 자동 종료 |
| `Fixes #` | 버그 수정 완료 | 자동 종료 |
| `Refs #` | 관련 작업 (중간 PR) | 유지 |

**주의**: `Refs #`는 링크만 생성, Development 연결 안 됨

## Merge 방식

- **일반 merge**: 항상 사용 (커밋 이력 유지)
- **squash**: 금지 (이력 손실)

## 금지 사항

| 금지 | 올바른 예 |
|------|----------|
| `Fix workflow dispatch` | `[#107] ensia96 (2026-01-10)` |
| `[#107] ensia96 (260110)` | `[#107] ensia96 (2026-01-10)` |
| 어사이니 미지정 | `--assignee ensia96` |
| 이슈 연결 누락 | `Closes #107` 또는 `gh issue develop` |
