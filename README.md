# Smart Platform - Tools
Tools for Smart Platform
### Tools
```
- JMeter JMX test plans as performance tests
- PlantUML diagrams and markups as system architectures
- Postman collections for manual testing
- Shell scripts for automation of builds, run, etc.
- Docker Compose configuration to start the whole system
- Kubernetes infrastructure configuration
- Screenshots about the system
```
### Build script
```
Usage: ./build.sh [-u | --update -t | --tests -d | --docker]
Options:
    -h, --h         print help
    -u, --update    update git repositories
    -t, --tests     run unit and integration tests
    -d, --docker    build images, clean containers and images, start containers

Automation script for Smart-Platform.
It can clone/pull git repositories, build jars, build docker images.
```
### Start script
```
Usage: ./start.sh [-p | --prod]
Options:
    -h, --h         print help
    -p, --prod      prod environment settings"

Automation script for Smart-Platform.
It can start containers, delete old docker images and containers.
```
### Stop script
```
Usage: ./stop.sh
Options:
    -h, --h         print help

Automation script for Smart-Platform.
It can stop containers.
```
### Update script
```
Usage: ./update.sh
Options:
    -h, --h         print help

Automation script for Smart-Platform.
It can clone/pull git repositories.
```
### System architecture of Smart Platform
Applied software development techniques:
- Microservice Architecture
- API Gateway Pattern

![System Architecture](https://raw.githubusercontent.com/ProudProgrammer/smart-tools/master/plantuml/system-architecture.png)

### User Interface of Smart Platform
![User Interface](https://raw.githubusercontent.com/ProudProgrammer/smart-tools/master/screenshots/smart-platform.png)

### Swagger for Smart Platform
![Swagger](https://raw.githubusercontent.com/ProudProgrammer/smart-tools/master/screenshots/swagger.png)

### Kubernetes Dashboard for Smart Platform
![K8s Dashboard Workloads 1](https://raw.githubusercontent.com/ProudProgrammer/smart-tools/screenshots/k8s-dashboard-workloads-1.png)

![K8s Dashboard Workloads 2](https://raw.githubusercontent.com/ProudProgrammer/smart-tools/screenshots/k8s-dashboard-workloads-2.png)

![K8s Dashboard Nodes](https://raw.githubusercontent.com/ProudProgrammer/smart-tools/screenshots/k8s-dashboard-nodes.png)

### K9s Terminal-Based Interface for Kubernetes of Smart Platform
![K9s Pods](https://raw.githubusercontent.com/ProudProgrammer/smart-tools/screenshots/k9s-pods.png.png)

![K9s Logs](https://raw.githubusercontent.com/ProudProgrammer/smart-tools/screenshots/k9s-logs.png.png)
