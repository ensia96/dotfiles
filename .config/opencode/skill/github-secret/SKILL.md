---
name: github-secret
description: "GitHub Secret 관리 규칙"
---

# GitHub Secret

## 핵심 규칙

**Secret 추가/수정 시 반드시 사용자 검토 필수**

## 작업 전 확인

```bash
gh secret list
gh secret list --repo {owner}/{repo}  # 특정 저장소
```

## 작업 흐름

1. 기존 secret 목록 확인
2. 추가/수정할 secret 이름과 용도 정리
3. 사용자에게 검토 요청
4. 승인 후 실행
5. 결과 기록

## 검토 요청 형식

```markdown
## Secret 추가/수정 요청

현재: {gh secret list 결과}

| 작업 | 이름 | 용도 |
|------|------|------|
| 추가 | NEW_SECRET | {용도} |

진행해도 될까요?
```

## 실행 명령어

```bash
gh secret set {NAME}      # 추가 (대화형 입력)
gh secret delete {NAME}   # 삭제
```

## 기록

이슈/PR에 댓글로 기록:

```markdown
## Secret 작업 기록 - YYYY-MM-DD HH:MM
- 명령어: `gh secret set NEW_SECRET`
- 용도: {설명}
- 결과: 성공/실패
```

## 민감 정보 보호

- Secret 값은 **절대 기록하지 않음**
- 변수명과 용도만 기록
