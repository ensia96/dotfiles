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

---

## 형식

```
{type}: {title}
```

- 작업의 방향성을 제시
- 제목, 내용, 댓글을 통해 상세하게 설명/토의

## Types

| Type | 용도 | 설명 |
|------|------|------|
| `story` | 사용자 스토리 | 예상 요구사항 |
| `report` | 개선 제보 | 사용자가 제보한 개선점/문제 |
| `voc` | 개선사항 | report에서 도출된 실행 가능한 개선점 |
| `task` | 개발 작업 | 필요한 작업 |
| `bug` | 버그 수정 | 확인된 버그 해결 작업 |

## 이슈 흐름

```
고객 피드백 → [사용자] report 이슈 생성
                    ↓
           [사용자 + 에이전트] 분석/정제
                    ↓
              voc 또는 bug 이슈로 전환
```

## 예시

```
story: 사용자는 서비스를 이용하기 위해 로그인을 해야 한다.
report: 로그인 화면의 비밀번호 입력칸이 너무 작아서 불편하다.
report: 로그인 버튼을 눌렀는데 아무런 반응이 없다.
voc: 비밀번호 입력칸 크기 개선
task: Kubernetes Dashboard 로 전환
bug: LoadBalancer External IP pending 상태로 Dashboard 접속 불가
```

## 생성 명령어

```bash
gh issue create \
  --title "task: Kubernetes Dashboard 로 전환" \
  --assignee ensia96 \
  --body "## 배경
- 문제 상황 설명

## 변경 사항
- 예상 변경 내용

## 참조
- 관련 링크"
```

## 필수 항목

- [ ] **어사이니 지정**
- [ ] **명확한 제목**: `{type}: {title}`
- [ ] **배경/목적 설명**
