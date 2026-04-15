# Kubernetes Dashboard

Установка chart:

```bash
helm repo add kubernetes-dashboard https://kubernetes-retired.github.io/dashboard
helm repo update

helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard \
  --namespace kubernetes-dashboard \
  --create-namespace
```

Создание admin service account:

```bash
kubectl apply -f ./kubernetes-dashboard/dashboard-admin-sa.yaml
```

Получить token:

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

Port-forward:

```bash
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443
```

Открыть:

- `https://localhost:8443`
