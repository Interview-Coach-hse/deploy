# Deploy structure

Репозиторий переведён на `Helm only`. Plain manifests и `kustomize` entrypoints убраны, основной способ установки компонентов теперь только через локальные Helm chart'ы.

Разделение сделано по доменам, а не по инструментам. Для отдельного deployment-репозитория это удобнее: приложение, мониторинг, ingress, сертификаты и база разнесены по независимым зонам ответственности.

Структура:

- `app/backend/helm/interview-coach-backend` - Helm chart backend-приложения с явными `database.*` параметрами
- `app/frontend` - Helm chart frontend-приложения
- `app/bot` - место под deployment бота
- `app/worker` - место под deployment worker-процессов
- `monitoring/prometheus` - конфиг Prometheus, alert rules и manifest Alertmanager
- `monitoring/grafana` - provisioning Grafana
- `monitoring/loki` - конфиги Loki и Promtail
- `monitoring/tempo` - конфиг Tempo
- `monitoring/otel` - конфиг OpenTelemetry Collector
- `ingress-nginx/helm/interview-coach-ingress-nginx` - Helm chart ingress controller
- `cert-manager` - место под manifests cert-manager и issuers
- `database/postgres/helm/interview-coach-postgres` - Helm chart PostgreSQL
- `legacy/helm` - старый Helm chart, который сейчас смешивает backend и postgres в одном chart

Что уже можно поднять через Helm:

- `ingress-nginx/helm/interview-coach-ingress-nginx`
- `database/postgres/helm/interview-coach-postgres`
- `app/backend/helm/interview-coach-backend`
- `app/frontend`

Пример установки:

```bash
helm upgrade --install ingress-nginx ./ingress-nginx/helm/interview-coach-ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

helm upgrade --install postgres ./database/postgres/helm/interview-coach-postgres \
  --namespace interview-coach \
  --create-namespace

helm upgrade --install backend ./app/backend/helm/interview-coach-backend \
  --namespace interview-coach

helm upgrade --install frontend ./app/frontend \
  --namespace interview-coach
```

Что нужно заполнить руками перед деплоем:

- `app/backend/helm/interview-coach-backend/values.yaml`
- `app/frontend/values.yaml`
- `database/postgres/helm/interview-coach-postgres/values.yaml`
- `ingress-nginx/helm/interview-coach-ingress-nginx/values.yaml`

Обязательные значения для замены:

- DNS-имена:
  - `api.interview-coach.example.com`
  - `interview-coach.example.com`
- секреты:
  - `APP_SECURITY_JWT_SECRET`
  - `SPRING_MAIL_PASSWORD`
  - `POSTGRES_PASSWORD`
- почтовые настройки:
  - `APP_MAIL_FROM`
  - `SPRING_MAIL_USERNAME`
  - `SPRING_MAIL_HOST`
  - `SPRING_MAIL_PORT`
- storage:
  - `database/postgres/helm/interview-coach-postgres/values.yaml`: `persistence.size`
  - `database/postgres/helm/interview-coach-postgres/values.yaml`: `persistence.storageClass`, если в кластере нет default storage class
- container images:
  - `interview-coach:latest`
  - `interview-coach-frontend:latest`
- ingress controller:
  - `ingress-nginx/helm/interview-coach-ingress-nginx/values.yaml`: `controller.service.type`
  - `ingress-nginx/helm/interview-coach-ingress-nginx/values.yaml`: `controller.image.tag`

Замечания:

- frontend сейчас ожидает backend по внешнему адресу `http://api...`, а не по внутреннему service DNS
- backend по умолчанию подключается к postgres service `interview-coach-postgres:5432`
- TLS по умолчанию отключён в `frontend` и `backend` chart'ах: `ingress.annotations: {}` и `ingress.tls: []`
- когда будешь включать HTTPS, верни `cert-manager.io/cluster-issuer` и заполни `ingress.tls` в:
  - `app/backend/helm/interview-coach-backend/values.yaml`
  - `app/frontend/values.yaml`

Почему так лучше:

- проще передавать владение между командами
- легче строить overlays по окружениям
- нет смешивания application manifests и monitoring-конфигов в одной папке

Рекомендация дальше:

- использовать новые независимые chart'ы для backend и postgres
- использовать community chart `prometheus-community/alertmanager` для alertmanager
- удалить `legacy/helm/interview-coach` после окончательной миграции
