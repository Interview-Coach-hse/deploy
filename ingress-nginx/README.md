# ingress-nginx

Локальный Helm chart для `ingress-nginx` controller находится в `helm/interview-coach-ingress-nginx`.

Пример установки:

```bash
helm upgrade --install ingress-nginx ./ingress-nginx/helm/interview-coach-ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace
```

Что проверить руками перед установкой:

- `controller.service.type`: `LoadBalancer` для managed Kubernetes, `NodePort` или MetalLB для bare metal
- `controller.image.tag`, если в кластере зафиксирована другая версия ingress-nginx
- `controller.replicaCount` и `controller.resources`
