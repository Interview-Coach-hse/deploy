# Deploy

Репозиторий находится в режиме `Helm only`: приложение, ingress, monitoring и dashboard разворачиваются Helm chart'ами или community chart'ами с локальными `values.yaml`.

## Структура

- `app/backend/helm` - Helm chart backend
- `app/frontend/helm` - Helm chart frontend
- `database/postgres/helm` - Helm chart PostgreSQL
- `ingress-nginx/helm` - локальный Helm chart ingress-nginx controller
- `monitoring/helm` - values для community chart'ов Prometheus, Grafana, Loki, Promtail, Tempo, OTel Collector
- `monitoring/dashboards` - готовые Grafana dashboard JSON
- `kubernetes-dashboard` - Helm install notes и admin service account для Kubernetes Dashboard
- `cert-manager` - заметки по cert-manager
- `vault` - values и заметки по HashiCorp Vault
- `external-secrets` - оператор и конфигурация интеграции Vault -> Kubernetes Secret
- `app/bot`, `app/worker` - заготовки под будущие сервисы

## Namespace'ы

Сейчас в репозитории используются такие namespace'ы:

- `ingress-nginx` - ingress controller
- `app` - frontend, backend, postgres
- `monitoring` - Prometheus, Grafana, Loki, Promtail, Tempo, OTel Collector
- `vault` - Vault
- `external-secrets` - External Secrets Operator
- `kubernetes-dashboard` - Kubernetes Dashboard

## Актуальные адреса

Текущая конфигурация завязана на сервер `45.139.78.241` и `nip.io`:

- frontend: `http://45.139.78.241.nip.io`
- backend: `http://api.45.139.78.241.nip.io`
- backend API base: `http://api.45.139.78.241.nip.io/api`
- grafana: `http://grafana.45.139.78.241.nip.io`

Важно: их нужно заменить в `values.yaml`, см. секцию ниже.

## Установка

### Один запуск для всего Helm-стека

Для всего, что в репозитории разворачивается через Helm, теперь можно использовать один общий файл:

```bash
helmfile sync
```

или обёртку:

```bash
./scripts/deploy-all.sh
```

Что войдёт в этот запуск:

- `vault`
- `external-secrets`
- `ingress-nginx`
- `postgres`
- `backend`
- `frontend`
- `prometheus`
- `loki`
- `promtail`
- `tempo`
- `otel-collector`
- `grafana`

Файл оркестрации:

- [`helmfile.yaml`](/Users/a.v.berezutskiy/Desktop/Dip/deploy/helmfile.yaml)

Важно:

- нужен установленный `helmfile`
- перед первым запуском всё равно нужно заполнить хосты в `values.yaml`
- если используешь Vault, секреты в `app/backend/helm/values.yaml` и `database/postgres/helm/values.yaml` больше не заполняются вручную
- `cert-manager` и `kubernetes-dashboard` сюда не включены, потому что в репозитории для них сейчас нет полноценного chart'а, только инструкции и манифесты

Ниже оставлены отдельные команды, если захочешь ставить компоненты по одному.

### 1. ingress-nginx

```bash
helm upgrade --install ingress-nginx ./ingress-nginx/helm \
  --namespace ingress-nginx \
  --create-namespace \
  -f ./ingress-nginx/helm/values.yaml
```

### 2. Vault

```bash
helmfile -l app=vault sync
```

### 3. External Secrets

```bash
helmfile -l app=external-secrets sync
helmfile -l app=external-secrets-config sync
```

### 4. PostgreSQL

```bash
helm upgrade --install postgres ./database/postgres/helm \
  --namespace app \
  --create-namespace \
  -f ./database/postgres/helm/values.yaml
```

### 5. Backend

```bash
helm upgrade --install backend ./app/backend/helm \
  --namespace app \
  -f ./app/backend/helm/values.yaml
```

### 6. Frontend

```bash
helm upgrade --install frontend ./app/frontend/helm \
  --namespace app \
  -f ./app/frontend/helm/values.yaml
```

### 7. Monitoring

Команды и values лежат в:

- [`monitoring/README.md`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/README.md)

Коротко:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

kubectl create namespace monitoring

helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace monitoring \
  --reset-values \
  -f ./monitoring/helm/prometheus-values.yaml

helm upgrade --install loki grafana/loki \
  --namespace monitoring \
  -f ./monitoring/helm/loki-values.yaml

helm upgrade --install promtail grafana/promtail \
  --namespace monitoring \
  -f ./monitoring/helm/promtail-values.yaml

helm upgrade --install tempo grafana/tempo \
  --namespace monitoring \
  -f ./monitoring/helm/tempo-values.yaml

helm upgrade --install otel-collector open-telemetry/opentelemetry-collector \
  --namespace monitoring \
  -f ./monitoring/helm/otel-collector-values.yaml

helm upgrade --install grafana grafana/grafana \
  --namespace monitoring \
  -f ./monitoring/helm/grafana-values.yaml
```

### 8. Kubernetes Dashboard

Инструкции и admin service account:

- [`kubernetes-dashboard/README.md`](/Users/sir/Desktop/Diplom/project/deploy/kubernetes-dashboard/README.md)
- [`kubernetes-dashboard/dashboard-admin-sa.yaml`](/Users/sir/Desktop/Diplom/project/deploy/kubernetes-dashboard/dashboard-admin-sa.yaml)

## Где обязательно заменить адреса

Чтобы развёртывание не осталось жёстко привязанным к `45.139.78.241`, замени IP/host в этих файлах:

### Frontend

- [`app/frontend/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/app/frontend/helm/values.yaml)

Поля:

- `runtimeConfig.apiBaseUrl`
- `ingress.hosts[].host`
- при включении TLS ещё и `ingress.tls`

Сейчас там:

- `http://api.45.139.78.241.nip.io/api`
- `45.139.78.241.nip.io`

### Backend

- [`app/backend/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/app/backend/helm/values.yaml)

Поля:

- `env.corsAllowedOrigins`
- `env.frontendPasswordResetUrl`
- `ingress.hosts[].host`
- при включении TLS ещё и `ingress.tls`

Сейчас там:

- `http://45.139.78.241.nip.io`
- `http://45.139.78.241.nip.io/reset-password`
- `api.45.139.78.241.nip.io`

### Grafana

- [`monitoring/helm/grafana-values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/helm/grafana-values.yaml)

Поля:

- `ingress.hosts`
- при необходимости `adminPassword`
- при включении TLS ещё и `ingress.tls`

Сейчас там:

- `grafana.45.139.78.241.nip.io`

## Что ещё нужно заполнить руками

### Секреты

При текущей конфигурации секреты должны жить в Vault, а не в Git. `values.yaml` теперь хранит только не-секретные настройки и mapping до путей Vault.

#### Что хранить в Vault

- `secret/interview-coach/backend`
  - `APP_SECURITY_JWT_SECRET`
  - `SPRING_MAIL_PASSWORD`
- `secret/interview-coach/postgres`
  - `POSTGRES_DB`
  - `POSTGRES_USER`
  - `POSTGRES_PASSWORD`

#### Инициализация Vault

После установки релиза `vault`:

```bash
kubectl exec -n vault vault-0 -- vault operator init
kubectl exec -n vault vault-0 -- vault operator unseal
kubectl exec -n vault vault-0 -- vault login
kubectl exec -n vault vault-0 -- vault secrets enable -path=secret kv-v2
kubectl exec -n vault vault-0 -- vault auth enable kubernetes
```

#### Загрузка секретов в Vault

```bash
kubectl exec -n vault vault-0 -- vault kv put secret/interview-coach/backend \
  APP_SECURITY_JWT_SECRET="replace-me" \
  SPRING_MAIL_PASSWORD="replace-me"

kubectl exec -n vault vault-0 -- vault kv put secret/interview-coach/postgres \
  POSTGRES_DB="interview_coach" \
  POSTGRES_USER="interview_coach" \
  POSTGRES_PASSWORD="replace-me"
```

#### Policy и role для External Secrets Operator

Сначала настрой Kubernetes auth внутри Vault:

```bash
export SA_TOKEN="$(kubectl create token -n external-secrets external-secrets)"
export SA_CA_CRT="$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode)"
export K8S_HOST="$(kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.server}')"
```

```bash
kubectl exec -i -n vault vault-0 -- vault write auth/kubernetes/config \
  token_reviewer_jwt="$SA_TOKEN" \
  kubernetes_host="$K8S_HOST" \
  kubernetes_ca_cert="$SA_CA_CRT"
```

Создай policy:

```bash
cat <<'EOF' >/tmp/external-secrets-policy.hcl
path "secret/data/interview-coach/*" {
  capabilities = ["read"]
}
EOF

kubectl cp /tmp/external-secrets-policy.hcl vault/vault-0:/tmp/external-secrets-policy.hcl
kubectl exec -n vault vault-0 -- vault policy write external-secrets /tmp/external-secrets-policy.hcl
kubectl exec -n vault vault-0 -- vault write auth/kubernetes/role/external-secrets \
  bound_service_account_names=external-secrets \
  bound_service_account_namespaces=external-secrets \
  policies=external-secrets \
  ttl=1h
```

- [`app/backend/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/app/backend/helm/values.yaml)
  - `externalSecrets.data`
- [`database/postgres/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/database/postgres/helm/values.yaml)
  - `externalSecrets.data`
- [`monitoring/helm/grafana-values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/helm/grafana-values.yaml)
  - `adminPassword`

  

### Почта

#### Всё что связано с постой на данный момент выключено, для тестирования так и оставить

- [`app/backend/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/app/backend/helm/values.yaml)
  - `env.mailFrom`
  - `env.springMailHost`
  - `env.springMailPort`
  - `env.springMailUsername`

Если почта не нужна, оставляй `mailEnabled: false`.

### Образы

- [`app/backend/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/app/backend/helm/values.yaml)
  - `image.repository`
  - `image.tag`
- [`app/frontend/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/app/frontend/helm/values.yaml)
  - `image.repository`
  - `image.tag`

  актуальный образы уже стоят, рекомендуется не менять

### Storage

- [`database/postgres/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/database/postgres/helm/values.yaml)
  - `persistence.size`
  - `persistence.storageClass`
- [`monitoring/helm/grafana-values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/helm/grafana-values.yaml)
  - `persistence.size`
- [`monitoring/helm/loki-values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/helm/loki-values.yaml)
  - `singleBinary.persistence.size`
- [`monitoring/helm/tempo-values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/helm/tempo-values.yaml)
  - `persistence.size`
- [`monitoring/helm/prometheus-values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/helm/prometheus-values.yaml)
  - `server.persistentVolume.size`

## Что важно знать

- frontend ходит в backend по внешнему адресу, а не по внутреннему Kubernetes service DNS
- backend подключается к postgres по service name `interview-coach-postgres:5432`
- OTel Collector находится в namespace `monitoring`, поэтому backend использует полный DNS:
  - `otel-collector.monitoring.svc.cluster.local:4318/v1/traces`
- если меняешь только `ConfigMap`/`Secret` values, pod'ы могут не перезапуститься автоматически
- для ручного перезапуска после изменения values:

```bash
kubectl rollout restart deploy/interview-coach-backend -n app
kubectl rollout restart deploy/interview-coach-frontend -n app
kubectl rollout restart statefulset/interview-coach-postgres -n app
```

## Grafana dashboards

Готовые JSON для импорта:

- [`monitoring/dashboards/application-overview.json`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/dashboards/application-overview.json)
- [`monitoring/dashboards/platform-overview.json`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/dashboards/platform-overview.json)
- [`monitoring/dashboards/logs-overview.json`](/Users/sir/Desktop/Diplom/project/deploy/monitoring/dashboards/logs-overview.json)


docker buildx build --platform linux/amd64 -t sirlazybone/interview-backend:0.1.5 --push .

docker buildx build --platform linux/amd64 -t sirlazybone/interview-frontend:0.1.5 --push .
