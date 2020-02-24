#!/bin/bash
#
# Starter script for Smart Platform

COLOR_HEADER="\033[7;49;36m"
COLOR_RESET="\033[0m"

# 0 - project name
# 1 - git repository
# 2 - service port
LOTTERY_SERVICE="lottery-service:1.0-SNAPSHOT;8081"
EDGE_SERVICE="edge-service:1.0-SNAPSHOT;8080"

cd ../../
MAIN_DIR=$(pwd)

function print_help() {
  echo "Usage: ./start.sh [-u | --update -t | --tests -d | --docker]"
  echo "Options:"
  echo "    -h, --h         print help"
  echo ""
  echo "Automation script for Smart-Platform."
  echo "It can start containers, delete old docker images and containers."
}

function process_args() {
  while [[ ${#} -gt 0 ]]; do
    case "${1}" in
    -h | --help) print_help && exit 0 ;;
    esac
    shift
  done
}

function check_dependencies() {
  echo -e "\n${COLOR_HEADER}Checking dependencies...${COLOR_RESET}"
  command -v jq >/dev/null 2>&1 || {
    echo >&2 "Jq is not installed. Exiting..."
    exit 0
  }
  command -v docker >/dev/null 2>&1 || {
    echo >&2 "Docker is not installed. Exiting..."
    exit 0
  }
}

function clean_containers_and_images() {
  echo -e "\n${COLOR_HEADER}Cleaning up docker containers and images...${COLOR_RESET}"
  docker container rm -f $(docker ps | grep "$(docker images | grep "^<none>" | awk '{ print $3 }')" | awk '{ print $1 }')
  docker system prune -f
}

function start_containers() {
  echo -e "\n${COLOR_HEADER}Starting containers...${COLOR_RESET}"
  LOTTERY_SERVICE_PORT=$(echo "${LOTTERY_SERVICE}" | cut -d ';' -f 2)
  LOTTERY_SERVICE_IMAGE=$(echo "${LOTTERY_SERVICE}" | cut -d ';' -f 1)
  EDGE_SERVICE_PORT=$(echo "${EDGE_SERVICE}" | cut -d ';' -f 2)
  EDGE_SERVICE_IMAGE=$(echo "${EDGE_SERVICE}" | cut -d ';' -f 1)
  GATEWAY=$(docker network inspect bridge | jq -r '.[0].IPAM.Config | .[0].Gateway')
  docker run -d -p "${LOTTERY_SERVICE_PORT}:${LOTTERY_SERVICE_PORT}" "$LOTTERY_SERVICE_IMAGE"
  docker run -d -p "${EDGE_SERVICE_PORT}:${EDGE_SERVICE_PORT}" -e lottery.service.base.url="${GATEWAY}:${LOTTERY_SERVICE_PORT}" "$EDGE_SERVICE_IMAGE"
}

function init() {
  START_TIME=$SECONDS
  check_dependencies
  clean_containers_and_images
  start_containers
  ELAPSED_TIME=$(("$SECONDS" - "$START_TIME"))
  ((SEC = ELAPSED_TIME % 60, ELAPSED_TIME /= 60, MIN = ELAPSED_TIME % 60, HRS = ELAPSED_TIME / 60))
  TIMESTAMP=$(printf "%02d:%02d:%02d" ${HRS} ${MIN} ${SEC})
  echo -e "\n${COLOR_HEADER}Start script total time:${COLOR_RESET} ${TIMESTAMP}"
}

process_args "${@}"
init
