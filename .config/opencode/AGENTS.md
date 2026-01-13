# Agent Guidelines

> 전역 가이드라인. 규칙 강제는 hooks/permission이 담당. 이 문서는 value judgment 참조용.

---

## Scope

**Agent utilization only**
- 이 시스템은 AI 에이전트 활용 체계에만 적용
- 팀 협업 규칙 아님
- 사용자가 에이전트 밖에서 직접 작업 시 = 사용자 책임

---

## Hook Enforcement

> 아래 규칙은 구조적으로 강제됨

| 레이어 | 역할 | 파일 |
|--------|------|------|
| **Permission** | allow/ask 제어 (DENY 없음, 사용자 판단에 위임) | `oh-my-opencode.json` |
| **Plugin Hook** | 형식 검증 및 차단 (throw Error) | `plugin/validate-git.ts` |

### 차단됨 (Plugin Hook)

| 명령 | 이유 |
|------|------|
| `git checkout -b`, `git switch -c` | `gh issue develop` 사용 필수 |
| `git branch` 조작 (생성/삭제/이름변경) | 읽기만 허용 (`-a`, `-r`, `-v`, `--list`, 인자 없음) |
| `gh pr merge --squash/--rebase` | Regular merge only |
| 커밋 메시지 형식 불일치 | `{type}: {한글 메시지}` 필수 |
| 브랜치 이름 형식 불일치 | `{issue}/{worker}/{YYYY-MM-DD}` 필수 |
| PR 제목 형식 불일치 | `[#{issue}] {worker} ({YYYY-MM-DD})` 필수 |

### 확인 필요 (ask)

| 명령 | 이유 |
|------|------|
| `git push origin dev/main` | PR 통해 진행 권장 |
| `git push --force` | 위험한 작업 |
| `git reset --hard` | 되돌릴 수 없음 |
| `gh pr merge` | merge 확인 |
| PR base branch 불일치 | dev가 있으면 dev로 |

---

## Workflow

```
Reality -> Issue -> Branch -> Commit -> PR -> dev -> main -> Reality
```

예외는 **hotfix**뿐.

---

## Conventions

### Branch

- **형식**: `{issue}/{worker}/{YYYY-MM-DD}`
- **생성**: `gh issue develop {issue} --checkout --name "{형식}"` (이슈 자동 연결)
- **hotfix**: `hotfix/{worker}/{YYYY-MM-DD}`

### Commit

- **형식**: `{type}: {한글 메시지}`
- **type**: feat / fix / docs / chore (저장소 관례 우선)
- **단위**: atomic (하나의 커밋 = 하나의 독립적 변경)
- **자기완결**: 제3자가 메시지만 보고 변경 파악 가능

### Issue

- **제목**: `{type}: {제목}`
- **type**: story / report / voc / task / bug
- **본문**: 배경/목적, 완료 조건

```markdown
## Purpose
{1줄: 왜 필요한가}

## Done when
- [ ] {완료 조건 1}
- [ ] {완료 조건 2}
```

### PR

- **제목**: `[#{issue}] {worker} ({YYYY-MM-DD})`
- **base**: dev (있으면) / main (없으면)
- **연결**: `Closes #` / `Fixes #` / `Refs #`

```markdown
## Summary
{1줄: 무엇을 변경했는가}

## Why
{1줄: 왜 이렇게 변경했는가}

## Verification
- [ ] 테스트 통과
- [ ] 수동 검증 완료

## Links
Closes #{issue}
```

---

## Judgment Guidelines

### Atomic Commit 기준

- **분리해야 하는 것**
  - 리네이밍 + 기능 변경 -> 별도 커밋
  - 포맷팅/정리 + 로직 변경 -> 별도 커밋
  - 서로 다른 기능 -> 별도 커밋

- **하나로 묶어도 되는 것**
  - 한 기능을 위한 여러 파일 변경
  - 관련된 테스트 추가

### PR Summary/Why 작성

- **Summary**: 무엇을 변경했는가 (1줄)
  - Good: "로그인 API 응답에 토큰 만료 시간 추가"
  - Bad: "수정", "업데이트", "개선"

- **Why**: 왜 이렇게 변경했는가 (1줄)
  - Good: "클라이언트에서 토큰 갱신 시점 판단 필요"
  - Bad: "필요해서", "요청 받아서"

### 검증 기대치

| 변경 범위 | 최소 검증 |
|----------|----------|
| 단일 파일/설정 | 변경 확인 |
| 로직 변경 | 관련 기능 동작 확인 |
| API 변경 | 엔드포인트 테스트 |
| 의존성 추가 | 빌드/설치 확인 |

### 사실/의견 검증

- **사실**: 추측 금지, 확인된 정보만 근거
- **의견**: 동의해도 "왜" 동의하는지 근거 제시
- **검증 불가 시**: 가정 명시 + 범위 한정 + 사용자 승인

### 네이밍 원칙

- **역할 기반**: 구현이 아닌 역할을 설명 (traefik → controller)
- **저장소 패턴 우선**: 기존 네이밍 먼저 따름
- **일관성**: 같은 종류는 같은 패턴

---

## Exception Policy

### Hotfix 조건

다음 중 하나에 해당할 때만:
- 서비스 다운/장애
- 보안 취약점
- 데이터 손실 위험

### Hotfix 절차

1. main에 직접 커밋/머지
2. **즉시** dev로 propagation (PR 또는 merge)
3. 사후 이슈 생성 (기록용)

### ASK 시 필수 정보

예외 승인 요청 시 포함할 것:
- **리스크**: 무엇이 잘못될 수 있는가
- **롤백**: 되돌릴 수 있는가, 어떻게
- **후속 조치**: 완료 후 필요한 작업

---

## Safety

### Secrets 금지

다음 파일은 절대 커밋 금지:
- `.env`, `.env.*`
- `credentials.*`, `secrets.*`
- `*.pem`, `*.key`
- `*token*`, `*password*` (설정 파일 내)

### 파괴적 명령 원칙

다음은 원칙적으로 금지 (필요 시 ASK):
- `git push --force`
- `git reset --hard`
- `git clean -fd`
- `rm -rf` (중요 경로)

### 기록 원칙

Git 커밋으로 추적되지 않는 행동 (kubectl, helm, terraform, gh secret 등):
- 이슈/PR 댓글로 기록 (명령어, 이유, 결과)
- 값 자체는 기록하지 않음

---

## Reference

상세 규칙은 `~/projects/memo/agent-workflow.md` 참조.
