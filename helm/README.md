# Helm
### Install Helm
```
winget install Helm.Helm
helm version
```
### Install Smart-Platform with Helm (same configuration as in k8s folder)
```
helm install smart-platform ./smart-platform
```
### Install Smart-Platform with Helm (in different environment with different configurations)
```
helm install smart-platform ./smart-platform \
  --set ingress.platform.host=staging.smart-platform.com \
  --set edgeService.replicaCount=1
```
### Checking rendered YAML before install
```
helm template smart-platform ./smart-platform
```
