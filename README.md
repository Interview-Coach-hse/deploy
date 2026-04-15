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
- `app/bot`, `app/worker` - заготовки под будущие сервисы

## Namespace'ы

Сейчас в репозитории используются такие namespace'ы:

- `ingress-nginx` - ingress controller
- `app` - frontend, backend, postgres
- `monitoring` - Prometheus, Grafana, Loki, Promtail, Tempo, OTel Collector
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
- перед первым запуском всё равно нужно заполнить секреты и хосты в `values.yaml`
- `cert-manager` и `kubernetes-dashboard` сюда не включены, потому что в репозитории для них сейчас нет полноценного chart'а, только инструкции и манифесты

Ниже оставлены отдельные команды, если захочешь ставить компоненты по одному.

### 1. ingress-nginx

```bash
helm upgrade --install ingress-nginx ./ingress-nginx/helm \
  --namespace ingress-nginx \
  --create-namespace \
  -f ./ingress-nginx/helm/values.yaml
```

### 2. PostgreSQL

```bash
helm upgrade --install postgres ./database/postgres/helm \
  --namespace app \
  --create-namespace \
  -f ./database/postgres/helm/values.yaml
```

### 3. Backend

```bash
helm upgrade --install backend ./app/backend/helm \
  --namespace app \
  -f ./app/backend/helm/values.yaml
```

### 4. Frontend

```bash
helm upgrade --install frontend ./app/frontend/helm \
  --namespace app \
  -f ./app/frontend/helm/values.yaml
```

### 5. Monitoring

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

### 6. Kubernetes Dashboard

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

- [`app/backend/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/app/backend/helm/values.yaml)
  - `secrets.jwtSecret`
  - `secrets.springMailPassword`
- [`database/postgres/helm/values.yaml`](/Users/sir/Desktop/Diplom/project/deploy/database/postgres/helm/values.yaml)
  - `database.password`
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
