#!/bin/bash
#
# Starter script for Smart Platform

DEFAULT_PROFILE=true
PROD_PROFILE=false

COLOR_HEADER="\033[7;49;36m"
COLOR_RESET="\033[0m"

# 0 - project name
# 1 - git repository
# 2 - service port
# 3 - remote debug port
# 4 - spring prod profile name
LOTTERY_SERVICE="lottery-service:1.0-SNAPSHOT;8081;-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5006;5006;prod"
EDGE_SERVICE="edge-service:1.0-SNAPSHOT;8080;-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005;5005;prod"
UI="smart-ui"

function print_help() {
  echo "Usage: ./start.sh [-p | --prod]"
  echo "Options:"
  echo "    -h, --help         print help"
  echo "    -p, --prod         prod environment settings"
  echo ""
  echo "Automation script for Smart-Platform."
  echo "It can start containers, delete old docker images and containers."
}

function process_args() {
  while [[ ${#} -gt 0 ]]; do
    case "${1}" in
    -h | --help) print_help && exit 0 ;;
    -p | --prod) PROD_PROFILE=true && DEFAULT_PROFILE=false ;;
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
  LOTTERY_SERVICE_IMAGE=$(echo "${LOTTERY_SERVICE}" | cut -d ';' -f 1)
  LOTTERY_SERVICE_PORT=$(echo "${LOTTERY_SERVICE}" | cut -d ';' -f 2)
  LOTTERY_SERVICE_JAVA_ARGS=$(echo "${LOTTERY_SERVICE}" | cut -d ';' -f 3)
  LOTTERY_SERVICE_DEBUG_PORT=$(echo "${LOTTERY_SERVICE}" | cut -d ';' -f 4)
  LOTTERY_SERVICE_PROD_PROFILE_NAME=$(echo "${LOTTERY_SERVICE}" | cut -d ';' -f 5)
  EDGE_SERVICE_IMAGE=$(echo "${EDGE_SERVICE}" | cut -d ';' -f 1)
  EDGE_SERVICE_PORT=$(echo "${EDGE_SERVICE}" | cut -d ';' -f 2)
  EDGE_SERVICE_JAVA_ARGS=$(echo "${EDGE_SERVICE}" | cut -d ';' -f 3)
  EDGE_SERVICE_DEBUG_PORT=$(echo "${EDGE_SERVICE}" | cut -d ';' -f 4)
  EDGE_SERVICE_PROD_PROFILE_NAME=$(echo "${EDGE_SERVICE}" | cut -d ';' -f 5)
  GATEWAY=$(docker network inspect bridge | jq -r '.[0].IPAM.Config | .[0].Gateway')
  if [[ ${PROD_PROFILE} == true ]]; then
    echo -e "Starting containers with prod profile..."
    mkdir -p "$(pwd)/logs/lottery-service-prod"
    mkdir -p "$(pwd)/logs/edge-service-prod"
    docker run -d \
    -p "${LOTTERY_SERVICE_PORT}:${LOTTERY_SERVICE_PORT}" \
    -v "$(pwd)/logs/lottery-service-prod:/smart/share/lottery/logs" \
    -e SPRING_PROFILES_ACTIVE="${LOTTERY_SERVICE_PROD_PROFILE_NAME}" \
    "$LOTTERY_SERVICE_IMAGE"
    docker run -d \
    -p "${EDGE_SERVICE_PORT}:${EDGE_SERVICE_PORT}" \
    -v "$(pwd)/logs/edge-service-prod:/smart/share/edge/logs" \
    -e SPRING_PROFILES_ACTIVE="${EDGE_SERVICE_PROD_PROFILE_NAME}" -e LOTTERY_SERVICE_BASE_URL="${GATEWAY}:${LOTTERY_SERVICE_PORT}" \
    "$EDGE_SERVICE_IMAGE"
  elif [[ ${DEFAULT_PROFILE} == true ]]; then
    echo -e "Starting containers with default profile..."
    mkdir -p "$(pwd)/logs/lottery-service-default"
    mkdir -p "$(pwd)/logs/edge-service-default"
    docker run -d \
    -p "${LOTTERY_SERVICE_PORT}:${LOTTERY_SERVICE_PORT}" -p "${LOTTERY_SERVICE_DEBUG_PORT}:${LOTTERY_SERVICE_DEBUG_PORT}" \
    -v "$(pwd)/logs/lottery-service-default:/smart/share/lottery/logs" \
    -e JAVA_ARGS="${LOTTERY_SERVICE_JAVA_ARGS}" \
    "$LOTTERY_SERVICE_IMAGE"
    docker run -d \
    -p "${EDGE_SERVICE_PORT}:${EDGE_SERVICE_PORT}" -p "${EDGE_SERVICE_DEBUG_PORT}:${EDGE_SERVICE_DEBUG_PORT}" \
    -v "$(pwd)/logs/edge-service-default:/smart/share/edge/logs" \
    -e LOTTERY_SERVICE_BASE_URL="${GATEWAY}:${LOTTERY_SERVICE_PORT}" -e JAVA_ARGS="${EDGE_SERVICE_JAVA_ARGS}" \
    "$EDGE_SERVICE_IMAGE"
  fi
}

function start_ui {
  cd ../../
  cd "$UI"
  start index.html
}

function init() {
  START_TIME=$SECONDS
  check_dependencies
  clean_containers_and_images
  start_containers
  start_ui
  ELAPSED_TIME=$(("$SECONDS" - "$START_TIME"))
  ((SEC = ELAPSED_TIME % 60, ELAPSED_TIME /= 60, MIN = ELAPSED_TIME % 60, HRS = ELAPSED_TIME / 60))
  TIMESTAMP=$(printf "%02d:%02d:%02d" ${HRS} ${MIN} ${SEC})
  echo -e "\n${COLOR_HEADER}Start script total time:${COLOR_RESET} ${TIMESTAMP}"
}

process_args "${@}"
init
