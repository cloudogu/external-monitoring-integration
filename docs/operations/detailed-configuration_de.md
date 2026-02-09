# Detaillierte Konfiguration

Für ein schnelles und einfaches Beispiel siehe [Schnellstart](quickstart_de.md).

## Namespaces

Wenn `namespaces.create` in den Werten auf true gesetzt ist (Default), erstellt diese Komponente alle Namespaces in
`namespaces.names` (Default: `[monitoring]`). Ihre eigenen Monitoring-Lösungen werden dann in diesen Namespaces
platziert.

## Secrets

In jedem Namespace von `namespaces.names` erstellt diese Komponente ein Secret, das die Zugangsdaten für die
Prometheus-Instanz des EcoSystems enthält, in dem Sie diese Komponente installiert haben.
Dieses Secret heißt `<ecosystem-namespace>-external-monitoring`, wobei `<ecosystem-namespace>` der Namespace Ihres
EcoSystems ist.
Die Schlüssel `prometheus_user` und `prometheus_password` enthalten jeweils den Benutzernamen und das Passwort.

## Verbinden Sie Ihr eigenes Grafana mit dem Prometheus des EcoSystems

Hinweis: Es wird davon ausgegangen, dass der Namespace Ihres EcoSystems `ecosystem` ist.

### Über Umgebungsvariablen

Der einfachste Weg (und wie es im obigen Beispiel gemacht wird) besteht darin, das Secret als Umgebungsvariablen in
Ihren Grafana-Container einzubinden, zum Beispiel:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-grafana
spec:
  containers:
    - name: grafana
      image: my-grafana-image
      envFrom:
        - secretRef:
            name: ecosystem-external-monitoring
```

Sie können dann die Umgebungsvariablen innerhalb der Prometheus-Datenquelle Ihres Grafana referenzieren:

```yaml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://k8s-prometheus.ecosystem.svc:9090
    access: proxy
    basicAuth: true
    basicAuthUser: $prometheus_user
    secureJsonData:
      basicAuthPassword: $prometheus_password
    jsonData:
      httpMethod: POST
      manageAlerts: true
      prometheusType: Prometheus
      cacheLevel: 'High'
```

### Über Mounts

Wenn Sie nicht möchten, dass alle Prozesse in Ihrem Container Zugriff auf die Secrets haben, können Sie das Secret auch
innerhalb des Containers mounten und den Zugriff über Dateiberechtigungen steuern:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-grafana
spec:
  volumes:
    - name: prometheus-credentials
      secret:
        secretName: ecosystem-external-monitoring
  containers:
    - name: grafana
      image: my-grafana-image
      volumeMounts:
        - name: prometheus-credentials
          mountPath: /var/secrets/prometheus
          readOnly: true
```

Die Schlüssel des Secrets sind dann in `/var/secrets/prometheus` als Dateien verfügbar.

Sie müssen sich jedoch dann überlegen, wie Sie die Secrets in Ihre Prometheus-Datenquelle injizieren.
In den meisten Anwendungsfällen sollte die Verwendung von Umgebungsvariablen viel einfacher und ausreichend sicher sein.

## Netzwerk-Richtlinien (Network Policies)

Die Standardkonfiguration fügt dem Namespace Ihres EcoSystems eine NetworkPolicy hinzu, die es Pods aus allen Namespaces
in `namespaces.names` ermöglicht, mit Prometheus über den `auth-proxy`-Port zu kommunizieren.

Wenn Sie dies weiter einschränken möchten, können Sie `global.networkPolicies.monitoringSelector` so einstellen, dass
nur die Pods über Labels übereinstimmen, von denen aus Sie auf Prometheus zugreifen möchten.

Weitere Optionen finden Sie in der `values.yaml`.
