# ctfd

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.7.6](https://img.shields.io/badge/AppVersion-3.7.6-informational?style=flat-square)

A Helm chart for Kubernetes

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity |
| autoscaling | object | `{"enabled":false,"maxReplicas":100,"minReplicas":1,"targetCPUUtilizationPercentage":80}` | Autoscaling |
| extraEnvVars | object | `{}` | Extra environment variables |
| extraEnvVarsCM | object | `{}` | Extra environment variables configmap |
| extraEnvVarsSecret | object | `{}` | Extra environment variables secret |
| fullnameOverride | string | `""` | Fullname override |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/ctfd/ctfd","tag":"3.7.6"}` | Image to use for the CTFd container |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy for the image |
| image.repository | string | `"ghcr.io/ctfd/ctfd"` | Repository to pull the image from |
| image.tag | string | `"3.7.6"` | Tag to use for the image |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress | object | `{"annotations":{},"className":"","enabled":false,"hosts":[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}],"tls":[]}` | Ingress |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | Ingress class |
| ingress.enabled | bool | `false` | Ingress enabled |
| livenessProbe | object | `{"httpGet":{"path":"/healthcheck","port":"http"},"initialDelaySeconds":180}` | Liveness probe |
| nameOverride | string | `""` | Name override |
| nodeSelector | object | `{}` | Node selector |
| persistence | object | `{"logs":{"enabled":false,"path":"/var/log/CTFd"},"uploads":{"enabled":false,"path":"/var/uploads"}}` | Persistence |
| podAnnotations | object | `{}` | Pod annotations |
| podLabels | object | `{}` | Pod labels |
| podSecurityContext | object | `{}` | Pod security context |
| readinessProbe | object | `{"httpGet":{"path":"/healthcheck","port":"http"},"initialDelaySeconds":120}` | Readiness probe |
| replicaCount | int | `1` | Number of replicas to run |
| resources | object | `{"limits":{"cpu":"100m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | Resources |
| securityContext | object | `{"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":false,"runAsNonRoot":true,"runAsUser":1001}` | Security context |
| service | object | `{"port":8000,"type":"ClusterIP"}` | Service |
| service.port | int | `8000` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount | object | `{"annotations":{},"automount":true,"create":true,"name":""}` | Service account |
| tolerations | list | `[]` | Tolerations |
| volumeMounts | list | `[]` | Additional volumeMounts |
| volumes | list | `[]` | Additional volumes |

