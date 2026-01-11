---
name: naming
description: "코드/리소스 네이밍 규칙"
---

# Naming

> **원칙**: 이름은 구현이 아닌 역할을 설명한다.

## 핵심 기준

1. **추상적**: 구현이 바뀌어도 이름은 유지
2. **본질적**: 부가 속성이 아닌 핵심 역할 기준
3. **참조 적합**: 외부에서 가져다 쓸 때 의미가 명확

## 케이스 규칙

| 컨텍스트 | 케이스 | 예시 |
|----------|--------|------|
| Terraform 리소스명 | snake_case | `dashboard_admin` |
| Kubernetes 리소스 | kebab-case | `ingress-dashboard` |
| 환경변수 | SCREAMING_SNAKE_CASE | `TF_VAR_cluster_token` |
| display_name / 라벨 | kebab-case | `platform-cluster-main` |
| 로컬 변수 (HCL) | kebab-case | `controller-values` |

## 리소스 네이밍

### 구현체 → 역할

```hcl
# Bad
helm_release.traefik
helm_release.portainer

# Good
helm_release.controller
helm_release.dashboard
```

| 구현체 | 추상 이름 |
|--------|----------|
| traefik, nginx, haproxy | `controller` |
| portainer, kubernetes-dashboard | `dashboard` |
| metrics-server, prometheus | `metrics` |

### 패턴

| 상황 | 패턴 | 예시 |
|------|------|------|
| 유일한 리소스 | `main` | `oci_core_vcn.main` |
| 역할로 구분 | 역할명 | `nsg.bastion`, `nsg.worker` |
| 환경으로 구분 | 환경명 | `namespace.dev`, `namespace.main` |
| 복합 | `{대상}-{기능}` | `service_account.dashboard-admin` |

### OCI display_name

`${local.project}-{type}-{name}`: `platform-subnet-private`

## 코드 네이밍

### 변수

```hcl
# values 패턴
controller-values
dashboard-values

# 설정값
log-retention-duration
tailscale-acl-tag
```

### 파일명 (Terraform)

| 파일명 | 내용 |
|--------|------|
| `compute.tf.json` | 클러스터, 노드풀, 인스턴스 |
| `network.tf.json` | VCN, 서브넷, DNS |
| `interface.tf.json` | Kubernetes 리소스 |
| `local.tf.json` | 로컬 변수 |
| `variable.tf.json` | 입력 변수 |

## 정렬/포매팅

- 나열되는 코드는 오름차순 정렬
- prettier 등 도구 설정이 있으면 도구 따름
- 없으면 기존 파일 스타일 참조

## 체크리스트

```
[ ] 이름이 역할을 설명하는가? (구현이 아닌)
[ ] 구현이 바뀌어도 이름이 유효한가?
[ ] 컨텍스트에 맞는 케이스를 사용했는가?
```
