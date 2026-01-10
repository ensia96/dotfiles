---
name: git-branch
description: "브랜치명 작성 규칙"
---

# Git Branch

## 형식

```
{issue number}/{worker}/{YYYY-MM-DD}
```

- issue에 의해 생성
- pull request를 통해 반영
- 날짜는 브랜치 생성 시점 기준

## 예시

```
107/ensia96/2026-01-10
107/ensia96/2026-01-11
108/ensia96/2026-01-12
```

## 생성 방법

### 방법 1: gh issue develop (권장)
```bash
gh issue develop 107 --name "107/ensia96/2026-01-10"
```
- 이슈와 브랜치 자동 연결
- PR 생성 시 Development 연결 자동화

### 방법 2: git checkout
```bash
git checkout -b "107/ensia96/2026-01-10"
```
- PR 본문에 `Closes #107` 필요

## 금지 사항

| 금지 | 올바른 예 |
|------|----------|
| `fix/workflow-dispatch-apply` | `107/ensia96/2026-01-10` |
| `feature/add-dashboard` | `108/ensia96/2026-01-11` |
| `107/ensia96/260110` | `107/ensia96/2026-01-10` |
| `107/ensia96/2025-01-10` | `107/ensia96/2026-01-10` (연도 확인) |

## 체크리스트

- [ ] 이슈 번호가 맞는가?
- [ ] 작업자 이름이 맞는가?
- [ ] 날짜가 오늘인가? (YYYY-MM-DD)
- [ ] 연도가 맞는가? (현재 연도)
