# Quickstart

The following depicts an example setup utilizing the official Grafana Helm chart.
For more in-depth configuration, see [detailed configuration](detailed-configuration_en.md).

**Warning**: This example does **not** reflect best practices and should **not** be used
in a production environment without further research.

1. Make sure to have the `k8s-prometheus` component installed in your EcoSystem.
2. Install this `external-monitoring-integration` component in your EcoSystem.
3. Add the `grafana` Helm repository:
   ```shell
   helm repo add grafana https://grafana.github.io/helm-charts
   helm repo update
   ```
4. Deploy the Grafana Helm chart with our [custom values](grafana-values.yaml):
   ```shell
   helm upgrade -i external-grafana grafana/grafana \
     --values docs/operations/grafana-values.yaml \
     --namespace monitoring
   ```
   This configures your EcoSystem's Prometheus as a datasource and adds an example dashboard.
5. Extract the Grafana admin password:
   ```shell
   kubectl get secret -n monitoring external-grafana \
     -o jsonpath="{.data.admin-password}" \
     | base64 --decode ; echo
   ```
6. Expose the Grafana instance locally:
   ```shell
   export POD_NAME=$(kubectl get pods -n monitoring -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=external-grafana" -o jsonpath="{.items[0].metadata.name}")
   kubectl -n monitoring port-forward $POD_NAME 3000
   ```
   Now, the Grafana instance should be accessible at http://localhost:3000.
   You can log in with username `admin` and the password from the previous step.
