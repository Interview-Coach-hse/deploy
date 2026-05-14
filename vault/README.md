# Vault

Этот каталог хранит локальный минимальный Helm chart для HashiCorp Vault под single-node Kubernetes-кластер.

## Что разворачивается

- `Vault` как один `StatefulSet`
- `PersistentVolumeClaim` для хранения данных
- `Service` внутри кластера на `8200`

## Что важно после установки

После `helmfile sync` Vault еще не готов к работе с секретами, пока его не инициализировать и не распечатать:

```bash
kubectl exec -n vault vault-0 -- vault operator init
kubectl exec -n vault vault-0 -- vault operator unseal
kubectl exec -n vault vault-0 -- vault login
```

Дальше нужно:

1. Включить KV v2:

```bash
kubectl exec -n vault vault-0 -- vault secrets enable -path=secret kv-v2
```

2. Включить Kubernetes auth:

```bash
kubectl exec -n vault vault-0 -- vault auth enable kubernetes
```

3. Загрузить секреты для приложения:

```bash
kubectl exec -n vault vault-0 -- vault kv put secret/interview-coach/backend \
  APP_SECURITY_JWT_SECRET="replace-me" \
  SPRING_DATASOURCE_PASSWORD="replace-me" \
  SPRING_MAIL_PASSWORD="replace-me"

kubectl exec -n vault vault-0 -- vault kv put secret/interview-coach/postgres \
  POSTGRES_DB="interview_coach" \
  POSTGRES_USER="interview_coach" \
  POSTGRES_PASSWORD="replace-me"
```

4. Создать policy и роль для `External Secrets Operator`.

Подробные шаги ниже описаны в общем [README.md](/Users/sir/Desktop/Diplom/project/deploy/README.md).
