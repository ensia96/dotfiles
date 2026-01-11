---
name: shell-command
description: "쉘 명령어 실행 범위 및 기록 규칙"
---

# Shell Command

> ⚠️ **GATE SKILL**: 쉘 명령어(kubectl, terraform, helm, gh, docker 등) 실행 전 반드시 이 스킬을 로드하라.
> 
> **BLOCKING**: "실행 범위 확인" 없이 쉘 명령어 실행 금지.

---

## 핵심 철학

> **"Git 커밋으로 추적되지 않는 모든 행동은 기록되어야 한다."**

매뉴얼 동작이 발생하면, 그것이 예외 상황(코딩 실수, 긴급 수정 등)의 결과이건 계획된 작업이건, **근거 없고 이력 없는 행동이 되지 않도록** 기록한다.

---

## 위험 등급 기준

에이전트 자가 판단을 위한 기준:

| 등급 | 설명 | 예시 | 필요 조치 |
|------|------|------|----------|
| **읽기** | 상태 조회만 | `kubectl get`, `terraform state list`, `helm status` | 자동 실행 가능 |
| **쓰기** | 리소스 생성/수정 | `kubectl apply`, `helm install`, `terraform apply` | 사용자 승인 후 실행 |
| **삭제** | 리소스 제거 | `kubectl delete`, `helm uninstall`, `terraform destroy` | 사용자 승인 + 롤백 계획 |
| **프로덕션** | 운영 환경 영향 | prod 네임스페이스, 실서비스 | 사용자 승인 + 영향 범위 고지 |

---

## 실행 범위 확인 (BLOCKING)

**작업 시작 시 사용자에게 실행 가능 범위를 검토받는다.**

### 검토 요청 형식

```markdown
## 쉘 명령어 실행 범위 확인

이 작업에서 다음 명령어들을 사용할 수 있습니다:

| 도구 | 예상 사용 | 위험 등급 |
|------|----------|----------|
| kubectl | get, describe, logs | 읽기 |
| kubectl | apply, delete | 쓰기/삭제 |
| helm | list, status | 읽기 |
| terraform | plan | 읽기 |
| terraform | apply | 쓰기 |

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
| **kubectl** | apply, delete, patch, exec, rollout |
| **helm** | install, upgrade, rollback, uninstall |
| **terraform** | plan, apply, destroy, import |
| **gh** | secret set, issue create, pr merge |
| **docker** | run, exec, rm, build |

---

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

---

## 기록 위치

| 상황 | 기록 위치 |
|------|----------|
| 이슈 작업 중 | 이슈 댓글 |
| PR 작업 중 | PR 댓글 |
| 긴급 조치 | 관련 이슈 또는 새 이슈 생성 |

---

## 되돌릴 수 없는 작업

원칙:
1. **재활용 우선** - 기존 리소스/토큰 등 활용 가능한지 먼저 확인
2. **사전 승인** - 새로 생성해야 하면 사용자 승인 후 실행
3. **기록** - 이슈/PR에 실행 내용과 이유 기록

---

## 기존 시스템 활용 확인

수동 실행 전 확인:

```
[ ] 활용 가능한 기존 리소스가 있는가?
[ ] 이 작업을 파이프라인(GitHub Actions 등)으로 할 수 있는가?
[ ] 자동화된 방법이 이미 존재하는가?
[ ] 수동 실행이 꼭 필요한 상황인가?
```

**기존 리소스 재활용 > 파이프라인 > 수동 실행**

---

## 민감 정보 보호

```bash
# Bad - 비밀값 노출
gh secret set API_KEY --body "sk-1234567890abcdef"

# Good - 값 마스킹 또는 생략
gh secret set API_KEY
```

---

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
