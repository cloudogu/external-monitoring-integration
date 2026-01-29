# Technical Details

For a quick-and-dirty deployment, see [quickstart](quickstart_en.md).

## Namespaces

If `namespaces.create` is set to true (the default) in the values, this component creates all the namespaces in
`namespaces.names` (default: `[monitoring]`). Your own monitoring solutions are then to go into these namespaces.

## Secrets

In every namespace of `namespaces.names`, this component creates a secret that contains credentials for the Prometheus
instance of the EcoSystem you installed this component in.
That secret is named `<ecosystem-namespace>-external-monitoring`, where `<ecosystem-namespace>` is the namespace of your
EcoSystem.
The keys `prometheus_user` and `prometheus_password` contain username and password respectively.

## Connect your own Grafana to the EcoSystem's Prometheus

Note: It is assumed that your EcoSystem's namespace is `ecosystem`.

### Via environment variables

The easiest way (and how it's done in the above example) is put the secret into your Grafana container as environment
variables, for example:

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

You can then reference the environment variables inside the Prometheus datasource of your Grafana:

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

### Via mounts

If you don't want all processes in your container to have access to the secrets, you can also mount the secret inside
the container and control access via file permissions:

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

The Secret's keys are then available in `/var/secrets/prometheus` as files.

However, then you have to think about how to inject the secrets into your Prometheus datasource.
For most use-cases, using environment variables should be much easier and sufficiently secure.

## Network Policies

The default configuration add a NetworkPolicy to your EcoSystem's namespace that allows Pods from all the namespaces in
`namespaces.names` to communicate with Prometheus on the `auth-proxy` Port.

If you want to restrict that further, you can set `global.networkPolicies.monitoringSelector` to match the Pods you want
to access Prometheus from via labels.

For further options see the `values.yaml`.