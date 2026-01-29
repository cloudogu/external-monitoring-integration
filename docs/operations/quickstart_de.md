# Schnellstart

Das Folgende zeigt eine beispielhafte Einrichtung unter Verwendung des offiziellen Grafana Helm-Charts.
Für eine tiefergehende Konfiguration siehe [detaillierte Konfiguration](detailed-configuration_de.md).

**Warnung**: Dieses Beispiel spiegelt **nicht** die Best Practices wider und sollte **nicht** ohne weitere Recherche in
einer Produktionsumgebung verwendet werden.

1. Stellen Sie sicher, dass die Komponente `k8s-prometheus` in Ihrem EcoSystem installiert ist.
2. Installieren Sie diese Komponente `external-monitoring-integration` in Ihrem EcoSystem.
3. Starten Sie `k8s-prometheus` neu:
   ```shell
   kubectl rollout restart statefulset --selector=k8s.cloudogu.com/component.name=k8s-prometheus -n ecosystem
   ```
4. Fügen Sie das `grafana` Helm-Repository hinzu:
   ```shell
   helm repo add grafana https://grafana.github.io/helm-charts
   helm repo update
   ```
5. Installieren Sie das Grafana Helm-Chart mit unseren [benutzerdefinierten Werten](grafana-values.yaml):
   ```shell
   helm upgrade -i external-grafana grafana/grafana \
     --values docs/operations/grafana-values.yaml \
     --namespace monitoring
   ```
   Dies konfiguriert das Prometheus Ihres EcoSystems als Datenquelle und fügt ein Beispiel-Dashboard hinzu.
6. Extrahieren Sie das Grafana-Administrator-Passwort:
   ```shell
   kubectl get secret -n monitoring external-grafana \
     -o jsonpath="{.data.admin-password}" \
     | base64 --decode ; echo
   ```
7. Machen Sie die Grafana-Instanz lokal verfügbar:
   ```shell
   export POD_NAME=$(kubectl get pods -n monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=external-grafana" -o jsonpath="{.items[0].metadata.name}")
   kubectl -n monitoring port-forward $POD_NAME 3000
   ```
   Nun sollte die Grafana-Instanz unter http://localhost:3000 erreichbar sein.
   Sie können sich mit dem Benutzernamen `admin` und dem Passwort aus dem vorherigen Schritt anmelden.
