#!/bin/bash
#
# Starter script for Smart Platform

COLOR_HEADER="\033[7;49;36m"
COLOR_RESET="\033[0m"

LOGGING_FILTER="smart-logging-filter;https://github.com/ProudProgrammer/smart-logging-filter.git"
LOTTERY_SERVICE_CLIENT="smart-lottery-service-client;https://github.com/ProudProgrammer/smart-lottery-service-client.git"
LOTTERY_SERVICE="smart-lottery-service;https://github.com/ProudProgrammer/smart-lottery-service.git;-Pdocker,fast;8081"
EDGE_SERVICE="smart-edge-service;https://github.com/ProudProgrammer/smart-edge-service.git;-Pdocker,fast;8080"

PROJECTS=("$LOGGING_FILTER" "$LOTTERY_SERVICE_CLIENT" "$LOTTERY_SERVICE" "$EDGE_SERVICE")

UPDATE=false

cd ../../
MAIN_DIR=$(pwd)

function print_help() {
    echo "Usage: ./start.sh [-u | --update]"
    echo "Options:"
    echo "    -h, --h         print help"
    echo "    -u, --update    update git repositories"
    echo ""
    echo "Automation script for Smart-Platform."
    echo "It can clone/pull git repositories, build jars, build docker images, start containers, delete old docker images and containers."
}

function process_args() {
    while [[ ${#} -gt 0 ]]; do
        case "${1}" in
          -h | --help) print_help && exit 0 ;;
          -u | --update) UPDATE=true ;;
        esac
        shift
    done
}

function check_dependencies(){
    echo -e "\n${COLOR_HEADER}Checking dependencies...${COLOR_RESET}"
    command -v git >/dev/null 2>&1 || { echo >&2 "Git is not installed. Exiting..."; exit -1; }
    command -v mvn >/dev/null 2>&1 || { echo >&2 "Maven is not installed. Exiting..."; exit -1; }
    command -v jq >/dev/null 2>&1 || { echo >&2 "Jq is not installed. Exiting..."; exit -1; }
    command -v docker >/dev/null 2>&1 || { echo >&2 "Docker is not installed. Exiting..."; exit -1; }
}

function clone_repositories() {
    IFS=';'
    for PROJECT in "${PROJECTS[@]}"
    do
        read -ra PROJECT_AS_ARRAY <<< "$PROJECT"
        ABSOLUTE_PATH="$MAIN_DIR/${PROJECT_AS_ARRAY[0]}"
        if [[ ! -d "$ABSOLUTE_PATH" ]]; then
            echo -e "\n${COLOR_HEADER}Cloning ${PROJECT_AS_ARRAY[0]}...${COLOR_RESET}"
            git clone "${PROJECT_AS_ARRAY[1]}"
        elif [[ ${UPDATE} == true ]]; then
            echo -e "\n${COLOR_HEADER}Updating ${PROJECT_AS_ARRAY[0]}...${COLOR_RESET}"
            (
                cd ${PROJECT_AS_ARRAY[0]}
                git checkout master
                git pull
            )
        fi
    done
    IFS=' '
}

function build_projects() {
    IFS=';'
    for PROJECT in "${PROJECTS[@]}"
    do
        read -ra PROJECT_AS_ARRAY <<< "$PROJECT"
        echo -e "\n${COLOR_HEADER}Building ${PROJECT_AS_ARRAY[0]}...${COLOR_RESET}"
        cd "$MAIN_DIR/${PROJECT_AS_ARRAY[0]}" || exit
        mvn clean install ${PROJECT_AS_ARRAY[2]}
    done
    IFS=' '
}

function clean_containers_and_images() {
    echo -e "\n${COLOR_HEADER}Cleaning up docker containers and images...${COLOR_RESET}"
    docker container stop $(docker ps | grep "$(docker images | grep "^<none>" | awk '{ print $3 }')" | awk '{ print $1}')
    docker container rm -f $(docker ps | grep "$(docker images | grep "^<none>" | awk '{ print $3 }')" | awk '{ print $1}')
    docker system prune -f
}

function start_containers() {
    echo -e "\n${COLOR_HEADER}Starting containers...${COLOR_RESET}"
    LOTTERY_SERVICE_PORT=$(echo "${LOTTERY_SERVICE}" | cut -d ';' -f 4)
    EDGE_SERVICE_PORT=$(echo "${EDGE_SERVICE}" | cut -d ';' -f 4)
    GATEWAY=$(docker network inspect bridge | jq -r '.[0].IPAM.Config | .[0].Gateway')
    docker run -d -p ${LOTTERY_SERVICE_PORT}:${LOTTERY_SERVICE_PORT} lottery-service:1.0-SNAPSHOT
    docker run -d -p ${EDGE_SERVICE_PORT}:${EDGE_SERVICE_PORT} -e lottery.service.base.url=${GATEWAY}:${LOTTERY_SERVICE_PORT} edge-service:1.0-SNAPSHOT
}

function init() {
    START_TIME=$SECONDS
    check_dependencies
    clone_repositories
    build_projects
    clean_containers_and_images
    start_containers
    ELAPSED_TIME=$(($SECONDS - $START_TIME))
    ((SEC=ELAPSED_TIME%60, ELAPSED_TIME/=60, MIN=ELAPSED_TIME%60, HRS=ELAPSED_TIME/60))
    TIMESTAMP=$(printf "%02d:%02d:%02d" ${HRS} ${MIN} ${SEC})
    echo -e "\n${COLOR_HEADER}Starter script total time:${COLOR_RESET} ${TIMESTAMP}"
}

process_args "${@}"
init
