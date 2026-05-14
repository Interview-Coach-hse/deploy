# External Secrets

Этот релиз устанавливает `External Secrets Operator`, который читает секреты из Vault и создает обычные Kubernetes `Secret` для workload'ов.

После установки остается:

1. Настроить `ClusterSecretStore` на Vault.
2. Создать в Vault policy и role для service account `external-secrets`.
3. Включить `externalSecrets.enabled` в chart'ах приложения.
