---
name: naming-resource
description: "인프라/리소스 네이밍 규칙"
---

# Naming - Resource

## 핵심 원칙

- **추상화 우선**: 구현체가 아닌 역할/기능 이름 사용
- **핵심 중심**: 부가 컴포넌트가 아닌 핵심 기능 기준
- **kebab-case**: 모든 이름에 kebab-case 사용

## 추상화

구현체가 바뀌어도 이름은 유지:

| 구현체 | 추상 이름 | 용도 |
|--------|----------|------|
| traefik | `controller` | ingress controller |
| portainer, kubernetes-dashboard | `dashboard` | 관리 대시보드 |
| metrics-server | `metrics` | 메트릭 수집 |

```hcl
# Bad - 구현체 노출
helm_release.traefik
helm_release.portainer

# Good - 역할 기반
helm_release.controller
helm_release.dashboard
```

## Terraform 리소스

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

## Kubernetes 리소스

패턴: `{type}-{name}` 또는 단순 `{name}`
```hcl
kubernetes_ingress_v1.dashboard
  → name: "ingress-dashboard"

kubernetes_namespace_v1.system
  → name: "system"
```

## OCI display_name

프로젝트명을 접두어로: `${local.project}-{type}-{name}`
```
platform-vcn
platform-subnet-private
platform-instance-bastion
platform-cluster-main
```

## NSG 보안 규칙

트래픽 흐름 표현: `{source}-{방향}-{target}`
```
bastion-to-global
cluster-from-worker-api
worker-from-https
```

## 서비스 참조

Helm chart 서비스 참조 시 핵심 기능 기준:
```
# Bad - 부가 컴포넌트
dashboard-kong-proxy

# Good - 핵심 기능
dashboard-kubernetes-dashboard-web
```
