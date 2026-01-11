---
name: naming-resource
description: "인프라/리소스 네이밍 규칙"
---

# Naming - Resource

## 핵심 철학

> **"이름은 구현체가 아닌 역할을 설명해야 한다."**

좋은 이름의 기준:
1. **추상적**: 구현체가 바뀌어도 이름은 유지
2. **본질적**: 부가 기능이 아닌 핵심 기능 기준
3. **참조 적합**: 외부에서 가져다 쓸 때 의미가 명확

---

## 추상화 원칙

### 구현체 → 역할

구현체가 바뀌어도 이름은 유지:

| 구현체 | 추상 이름 | 역할 |
|--------|----------|------|
| traefik, nginx, haproxy | `controller` | ingress controller |
| portainer, kubernetes-dashboard | `dashboard` | 관리 대시보드 |
| metrics-server, prometheus | `metrics` | 메트릭 수집 |
| external-dns, cloudflare-dns | `dns` | DNS 관리 |

```hcl
# Bad - 구현체 노출
helm_release.traefik
helm_release.portainer

# Good - 역할 기반
helm_release.controller
helm_release.dashboard
```

### 핵심 기능 기준

부가 컴포넌트가 아닌 핵심 기능으로:

```
# Bad - 부가 컴포넌트
dashboard-kong-proxy

# Good - 핵심 기능
dashboard-kubernetes-dashboard-web
```

---

## 네이밍 패턴

### 단일 리소스

유일하게 존재하는 리소스는 `main` 사용:

```hcl
oci_containerengine_cluster.main
oci_core_internet_gateway.main
cloudflare_zone.main
```

### 역할 기반

복수 존재할 때 역할로 구분:

```hcl
oci_core_network_security_group.bastion
oci_core_network_security_group.cluster
oci_core_network_security_group.worker
```

### 환경 기반

환경별로 구분:

```hcl
kubernetes_namespace_v1.dev
kubernetes_namespace_v1.main
kubernetes_namespace_v1.system
```

### 복합 네이밍

대상과 기능 조합 (`{대상}-{기능}`):

```hcl
kubernetes_service_account_v1.dashboard-admin
oci_monitoring_alarm.instance-cpu
oci_logging_log.subnet-private
```

---

## 리소스 유형별 패턴

### Kubernetes 리소스

패턴: `{type}-{name}` 또는 단순 `{name}`

```hcl
kubernetes_ingress_v1.dashboard
  → name: "ingress-dashboard"

kubernetes_namespace_v1.system
  → name: "system"
```

### OCI display_name

프로젝트명을 접두어로: `${local.project}-{type}-{name}`

```
platform-vcn
platform-subnet-private
platform-instance-bastion
platform-cluster-main
```

### NSG 보안 규칙

트래픽 흐름 표현: `{source}-{방향}-{target}`

```
bastion-to-global
cluster-from-worker-api
worker-from-https
```

---

## 케이스 규칙

| 컨텍스트 | 케이스 | 예시 |
|----------|--------|------|
| Terraform 리소스명 | `snake_case` 또는 kebab 허용 | `dashboard_admin` |
| Kubernetes 리소스 | `kebab-case` (DNS 규칙) | `ingress-dashboard` |
| 환경변수 | `SCREAMING_SNAKE_CASE` | `TF_VAR_cluster_token` |
| display_name / 라벨 | `kebab-case` | `platform-cluster-main` |

---

## 체크리스트

```
[ ] 이름이 역할을 설명하는가? (구현체가 아닌)
[ ] 구현체가 바뀌어도 이름이 유효한가?
[ ] 외부에서 참조할 때 의미가 명확한가?
[ ] 컨텍스트에 맞는 케이스를 사용했는가?
```
