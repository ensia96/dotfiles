---
name: naming-code
description: "변수/파일 네이밍 규칙"
---

# Naming - Code

## 핵심 철학

> **"이름은 구현 방식이 아닌 역할과 의도를 설명해야 한다."**

좋은 이름의 기준:
1. **추상적**: 구현이 바뀌어도 이름은 유지
2. **본질적**: 부가 속성이 아닌 핵심 역할 기준
3. **참조 적합**: 다른 코드에서 가져다 쓸 때 의미가 명확

---

## 기본 원칙

- **간결함**: 불필요한 접두어/접미어 지양
- **일관성**: 동일 컨텍스트 내 동일 패턴 유지

## Local 변수

### values 패턴
`{대상}-values`:
```hcl
controller-values
dashboard-values
metrics-values
```

### 설정값
kebab-case:
```hcl
log-retention-duration
tailscale-acl-tag
```

## 환경변수

대문자 + underscore (SCREAMING_SNAKE_CASE), 접두어로 그룹화:
```bash
TF_VAR_cluster_token
TF_VAR_region
CLOUDFLARE_API_TOKEN
```

## Terraform 파일

영역별로 분리:

| 파일명 | 내용 |
|--------|------|
| `compute.tf.json` | 연산 (클러스터, 노드풀, 인스턴스) |
| `network.tf.json` | 네트워크 (VCN, 서브넷, DNS) |
| `interface.tf.json` | 인터페이스 (Kubernetes 리소스) |
| `organization.tf.json` | 조직 (IAM, 예산, 로깅) |
| `storage.tf.json` | 스토리지 (버킷, 레지스트리) |
| `local.tf.json` | 로컬 변수 |
| `variable.tf.json` | 입력 변수 |
| `data.tf.json` | 데이터 소스 |
| `provider.tf.json` | 프로바이더 설정 |

## Workflow 파일

역할 기반 간결한 이름:
```
provision.yml  # 인프라 프로비저닝
deploy.yml     # 애플리케이션 배포
```

## Cloudflare 설정

기능 기반 이름:
```hcl
secure-mode      # always_use_https
security-level   # security_level
ssl-mode         # ssl
tls-version      # min_tls_version
websocket        # websockets
```

## 정렬 규칙

- JSON 키: 오름차순 (alphabetical)
- 환경변수: 오름차순
- import/export: 오름차순
- 일관성 있는 정렬로 diff 최소화

## 코드 포매팅

### 원칙
- prettier 기본 설정 사용
- 프로젝트에 `.prettierrc` 등 설정 파일이 있으면 해당 설정 따름
- 없으면 prettier 기본값

### 에이전트 행동
- 코드 작성 시 prettier 기본 스타일 준수
- 저장 시 자동 포매팅 적용됨을 인지
- 포매팅 규칙 불확실 시 기존 파일 스타일 참조

---

## 체크리스트

```
[ ] 이름이 역할을 설명하는가? (구현 방식이 아닌)
[ ] 구현이 바뀌어도 이름이 유효한가?
[ ] 다른 코드에서 참조할 때 의미가 명확한가?
[ ] 컨텍스트에 맞는 케이스를 사용했는가?
```
