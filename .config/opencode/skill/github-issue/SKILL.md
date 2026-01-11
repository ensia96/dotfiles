---
name: github-issue
description: "GitHub 이슈 생성 규칙"
---

# GitHub Issue

## 이슈 생성 판단

코드 수정 전:
1. git 저장소 확인
2. 기존 이슈 존재 확인 (`gh issue list --limit 1`)

| 상황 | 행동 |
|------|------|
| 저장소 + 이슈 있음 | 이슈 생성 (또는 기존 이슈 연결) |
| 저장소 + 이슈 없음 | "이슈를 생성할까요?" 확인 |
| 저장소 아님 | 이슈 불필요 |

## 형식

```
{type}: {title}
```

## 허용 Types

| Type | 용도 |
|------|------|
| `story` | 사용자 스토리 (예상 요구사항) |
| `report` | 개선 제보 (사용자가 제보한 문제) |
| `voc` | 개선사항 (report에서 도출된 실행 항목) |
| `task` | 개발 작업 |
| `bug` | 버그 수정 |

## 이슈 흐름

```
고객 피드백 → report 이슈 → 분석/정제 → voc 또는 bug 이슈로 전환
```

## 예시

```
story: 사용자는 서비스를 이용하기 위해 로그인을 해야 한다.
task: Kubernetes Dashboard 로 전환
bug: LoadBalancer External IP pending 상태로 접속 불가
```

## 생성 명령어

```bash
gh issue create \
  --title "task: Kubernetes Dashboard 로 전환" \
  --assignee ensia96 \
  --body "## 배경
- 문제 상황 설명

## 변경 사항
- 예상 변경 내용"
```

## 필수 항목

```
[ ] 어사이니 지정
[ ] 명확한 제목: {type}: {title}
[ ] 배경/목적 설명
```
