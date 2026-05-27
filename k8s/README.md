# Minikube Setup
### Start Minikube
```
minikube start --driver=hyperv --memory=4096 --cpus=2
```
### Check Minikube Status
```
minikube status
```
### Enable Minikube Addons
```
minikube addons enable dashboard
minikube addons enable metrics-server
minikube addons enable ingress
```
### Check Minikube Addons
```
kubectl get pods -n kubernetes-dashboard
kubectl get pods -n ingress-nginx
```
### Load Smart Platform Images into Minikube
```
minikube image load smart-lottery-service:1.0-SNAPSHOT
minikube image load smart-edge-service:1.0-SNAPSHOT
minikube image load smart-ui:1.0.0
```
### List Minikube Images
```
minikube image ls
```
### Remove Smart Platform Images into Minikube
In case of update, old one needs to be removed than loaded again
```
minikube image rm smart-lottery-service:1.0-SNAPSHOT
minikube image rm smart-edge-service:1.0-SNAPSHOT
minikube image rm smart-ui:1.0.0
```
### Connect Local Dir with Minikube Dir
```
minikube mount D:\Temp\smart-platform-logs:/mnt/logs
```
### Stop Minikube
```
minikube stop
```
# Kubernetes Setup
### Create Kubernetes Components of Smart Platform
```
kubectl apply -f .\config\smart-platform-namespace.yaml
kubectl apply -f .\config\smart-platform-configmap.yaml
kubectl apply -f .\smart-lottery-service\
kubectl apply -f .\smart-edge-service\
kubectl apply -f .\smart-ui\
```
### List Kubernetes Components of Smart Platform
```
kubectl get all -n smart-platform
```
# Access With Ingress
### Create Ingresses
```
kubectl apply -f .\dashboard\
kubectl apply -f .\config\smart-platform-ingress.yaml
```
### List Ingresses
```
kubectl get ingress -n kubernetes-dashboard
kubectl get ingress -n smart-platform
```
Example:
```
PS D:\GitRepos [backup]\smart-tools\k8s> kubectl get ingress -n kubernetes-dashboard
NAME                CLASS   HOSTS                          ADDRESS          PORTS   AGE
dashboard-ingress   nginx   smart-platform-dashboard.com   172.25.166.205   80      62s

PS D:\GitRepos [backup]\smart-tools\k8s> kubectl get ingress -n smart-platform
NAME                     CLASS   HOSTS                                                                 ADDRESS          PORTS   AGE
smart-platform-ingress   nginx   smart-platform.com,smart-egde-service.com,smart-lottery-service.com   172.25.166.205   80      3h14m
```
### Add records to Hosts file (Do not forget to save it)
Example (C:\Windows\System32\drivers\etc\hosts):
```
172.25.166.205 smart-platform-dashboard.com
172.25.166.205 smart-platform.com
172.25.166.205 smart-egde-service.com
172.25.166.205 smart-lottery-service.com
```
### Open with Browser
http://smart-platform-dashboard.com/<br>
http://smart-platform.com/
# Access Without Ingress
### Port-Forward to Reach Services Externally from the Cluster
```
kubectl port-forward service/smart-edge-service-service 8080:8080 -n smart-platform
kubectl port-forward service/smart-lottery-service-service 8081:8081 -n smart-platform
kubectl port-forward service/smart-ui-service 8001:8001 -n smart-platform
```
### Open a Proxy for Kubernetes Dashboard
```
minikube dashboard
```
# K9s Terminal-Based Interface
```
winget install derailed.k9s
k9s
```
