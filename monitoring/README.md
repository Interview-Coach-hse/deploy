# Monitoring

Monitoring переведён на community Helm charts.

Рекомендуемый namespace:

```bash
kubectl create namespace monitoring
```

Репозитории chart'ов:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
```

Установка:

```bash
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace monitoring \
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

Что заполнить руками:

- `monitoring/helm/grafana-values.yaml`:
  - `adminPassword`
  - `ingress.hosts`
- `monitoring/helm/prometheus-values.yaml`:
  - backend service DNS в `serverFiles.prometheus.yml`
- `monitoring/helm/otel-collector-values.yaml`:
  - при необходимости exporters/receivers под твой backend
- `monitoring/helm/loki-values.yaml`, `monitoring/helm/tempo-values.yaml`:
  - `persistence.size`
  - `persistence.storageClass`

Как это связано с приложением:

- Prometheus ходит в backend по внутреннему service DNS, а не по внешнему browser URL
- Grafana внутри кластера ходит в `prometheus`, `loki`, `tempo` тоже по service DNS
- в браузере открывается только Grafana, обычно через `Ingress`

Пример browser URL для сервера с IP `45.139.78.241`:

- Grafana: `http://grafana.45.139.78.241.nip.io`

После установки проверь:

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get ingress -n monitoring
```
