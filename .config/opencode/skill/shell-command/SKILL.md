---
name: shell-command
description: "쉘 명령어 실행 범위 및 기록 규칙"
---

# Shell Command

> **원칙**: Git 커밋으로 추적되지 않는 모든 행동은 기록되어야 한다.

## 위험 등급

| 등급 | 설명 | 예시 | 필요 조치 |
|------|------|------|----------|
| 읽기 | 상태 조회 | `kubectl get`, `terraform state list` | 자동 실행 가능 |
| 쓰기 | 리소스 생성/수정 | `kubectl apply`, `helm install` | 사용자 승인 후 |
| 삭제 | 리소스 제거 | `kubectl delete`, `terraform destroy` | 승인 + 롤백 계획 |
| 프로덕션 | 운영 환경 | prod 네임스페이스 | 승인 + 영향 범위 고지 |

## 실행 범위 확인

작업 시작 시 사용자에게 검토:

```markdown
## 쉘 명령어 실행 범위 확인

| 도구 | 예상 사용 | 위험 등급 |
|------|----------|----------|
| kubectl | get, describe | 읽기 |
| kubectl | apply, delete | 쓰기/삭제 |

어디까지 자동 실행해도 될까요?
```

## 기록 대상

Git 커밋으로 추적되지 않는 모든 쉘 명령어:
- kubectl: apply, delete, patch, exec, rollout
- helm: install, upgrade, rollback, uninstall
- terraform: plan, apply, destroy, import
- gh: secret set, issue create, pr merge

## 기록 형식

이슈/PR에 댓글:

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

| 상황 | 위치 |
|------|------|
| 이슈 작업 중 | 이슈 댓글 |
| PR 작업 중 | PR 댓글 |
| 긴급 조치 | 관련 이슈 또는 새 이슈 |

## 수동 실행 전 확인

```
[ ] 활용 가능한 기존 리소스가 있는가?
[ ] 파이프라인으로 할 수 있는가?
[ ] 수동 실행이 꼭 필요한가?
```

**우선순위**: 기존 리소스 재활용 > 파이프라인 > 수동 실행

## 민감 정보 보호

```bash
# Bad
gh secret set API_KEY --body "sk-1234567890"

# Good
gh secret set API_KEY  # 값 생략
```
