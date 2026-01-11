---
name: shell-command
description: "쉘 명령어 실행 범위 및 기록 규칙"
---

# Shell Command

## 실행 범위 확인 (BLOCKING)

**작업 시작 시 사용자에게 실행 가능 범위를 검토받는다.**

### 검토 요청 형식

```markdown
## 쉘 명령어 실행 범위 확인

이 작업에서 다음 명령어들을 사용할 수 있습니다:

| 도구 | 예상 사용 | 위험도 |
|------|----------|--------|
| kubectl | get, describe, logs | 낮음 (읽기) |
| kubectl | apply, delete | 중간 (쓰기) |
| helm | list, status | 낮음 (읽기) |
| terraform | plan | 낮음 |
| terraform | apply | 높음 |

어디까지 자동 실행해도 될까요?
```

### 범위 지정 예시

사용자 응답:
- "kubectl까지 OK"
- "terraform plan까지만"
- "읽기 명령어만"

→ 지정된 범위 내에서 자동 실행, 범위 외는 승인 요청

---

## 기록 대상

Git 커밋으로 추적되지 않는 모든 쉘 명령어 실행:

| 도구 | 예시 |
|------|------|
| **kubectl** | apply, delete, patch, exec |
| **helm** | install, upgrade, rollback |
| **terraform** | plan, apply, destroy |
| **gh** | secret set, issue create |
| **docker** | run, exec, rm |

## 기록 형식

GitHub 이슈/PR에 댓글로 기록:

```markdown
## 쉘 명령어 실행 기록 - YYYY-MM-DD HH:MM

### {작업 제목}
```bash
{실행한 명령어}
```
- 이유: {왜 이 작업을 했는지}
- 결과: {성공/실패, 영향}
```

## 기록 위치

| 상황 | 기록 위치 |
|------|----------|
| 이슈 작업 중 | 이슈 댓글 |
| PR 작업 중 | PR 댓글 |
| 긴급 조치 | 관련 이슈 또는 새 이슈 생성 |

## 기존 시스템 활용 확인

수동 실행 전 확인:

```
[ ] 이 작업을 파이프라인(GitHub Actions 등)으로 할 수 있는가?
[ ] 자동화된 방법이 이미 존재하는가?
[ ] 수동 실행이 꼭 필요한 상황인가?
```

**파이프라인 활용 가능하면 수동 실행 대신 파이프라인 사용 권장**

## 민감 정보 보호

```bash
# Bad - 비밀값 노출
gh secret set API_KEY --body "sk-1234567890abcdef"

# Good - 값 마스킹 또는 생략
gh secret set API_KEY
```

## 예시

```markdown
## 쉘 명령어 실행 기록 - 2026-01-10 14:30

### Service Resync 트리거
```bash
kubectl annotate svc traefik -n system resync=$(date +%s)
```
- 이유: CCM이 새 NLB 생성하도록 트리거
- 결과: 성공, External IP 할당됨
```
