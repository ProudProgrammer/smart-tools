# Smart Platform - Tools
Tools for Smart Platform
### Tools
```
- JMeter JMX test plans as performance tests
- PlantUML diagrams and markups as system architectures
- Postman collections for manual testing
- Shell scripts for automation of builds, run, etc.
```
### Starter script
```
Usage: ./start.sh [-u | --update -t | --tests -d | --docker]
Options:
    -h, --h         print help
    -u, --update    update git repositories
    -t, --tests     run unit and integration tests
    -d, --docker    build images, clean containers and images, start containers

Automation script for Smart-Platform.
It can clone/pull git repositories, build jars, build docker images, start containers, delete old docker images and containers.
```
### Stopper script
```
Usage: ./stop.sh
Options:
    -h, --h         print help

Automation script for Smart-Platform.
It can stop containers.
```
### Updater script
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
