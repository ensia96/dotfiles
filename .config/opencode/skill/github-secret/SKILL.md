---
name: github-secret
description: "GitHub Secret 관리 규칙"
---

# GitHub Secret

## 핵심 규칙

**Secret 추가/수정 시 반드시 사용자 검토 필수**

## 작업 전 필수 확인

```bash
# 기존 secret 목록 확인
gh secret list

# 특정 저장소
gh secret list --repo {owner}/{repo}
```

## 작업 흐름

```
1. 기존 secret 목록 확인
2. 추가/수정할 secret 이름과 용도 정리
3. 사용자에게 검토 요청
4. 승인 후 실행
5. 결과 기록
```

## 검토 요청 형식

```markdown
## Secret 추가/수정 요청

### 현재 상태
```
gh secret list 결과:
- SECRET_A
- SECRET_B
```

### 요청 사항
| 작업 | 이름 | 용도 |
|------|------|------|
| 추가 | NEW_SECRET | {용도 설명} |

### 확인 필요
- 이름이 기존 패턴과 맞는지?
- 중복되는 secret은 없는지?

진행해도 될까요?
```

## 실행 명령어

```bash
# Secret 추가 (값은 대화형 입력 또는 파이프)
gh secret set {NAME}

# 삭제
gh secret delete {NAME}
```

## 기록

Secret 작업은 이슈/PR에 기록:

```markdown
## Secret 작업 기록 - YYMMDD HH:MM

### {작업 내용}
```bash
gh secret set NEW_SECRET
```
- 용도: {설명}
- 결과: 성공/실패
```

## 민감 정보 보호

- Secret 값은 **절대 기록하지 않음**
- 명령어에서도 값 노출 금지
- 변수명과 용도만 기록
