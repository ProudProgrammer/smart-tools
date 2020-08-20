#!/bin/bash
#
# Starter script for Smart Platform

UPDATE=false
TESTS=false
DOCKER=false

COLOR_HEADER="\033[7;49;36m"
COLOR_RESET="\033[0m"

# 0 - project name
# 1 - git repository
# 2 - service port
LOGGING_FILTER="smart-logging-filter;https://github.com/ProudProgrammer/smart-logging-filter.git"
LOTTERY_SERVICE_CLIENT="smart-lottery-service-client;https://github.com/ProudProgrammer/smart-lottery-service-client.git"
LOTTERY_SERVICE="smart-lottery-service;https://github.com/ProudProgrammer/smart-lottery-service.git"
EDGE_SERVICE="smart-edge-service;https://github.com/ProudProgrammer/smart-edge-service.git"
SIMULATOR="smart-simulator;https://github.com/ProudProgrammer/smart-simulator.git"
UI="smart-ui;https://github.com/ProudProgrammer/smart-ui.git"
UI_ANGULARJS="smart-ui-angularjs;https://github.com/ProudProgrammer/smart-ui-angularjs.git"
TOOLS="smart-tools"

PROJECTS=("$LOGGING_FILTER" "$LOTTERY_SERVICE_CLIENT" "$LOTTERY_SERVICE" "$EDGE_SERVICE" "$SIMULATOR" "$UI" "$UI_ANGULARJS")

cd ../../
MAIN_DIR=$(pwd)

MAVEN_PROFILES_ACTIVE=""

function print_help() {
  echo "Usage: ./start.sh [-u | --update -t | --tests -d | --docker]"
  echo "Options:"
  echo "    -h, --h         print help"
  echo "    -u, --update    update git repositories"
  echo "    -t, --tests     run unit and integration tests"
  echo "    -d, --docker    build images, clean containers and images, start containers"
  echo ""
  echo "Automation script for Smart-Platform."
  echo "It can clone/pull git repositories, build jars, build docker images."
}

function process_args() {
  while [[ ${#} -gt 0 ]]; do
    case "${1}" in
    -h | --help) print_help && exit 0 ;;
    -u | --update) UPDATE=true ;;
    -t | --tests) TESTS=true ;;
    -d | --docker) DOCKER=true ;;
    esac
    shift
  done
}

function check_dependencies() {
  echo -e "\n${COLOR_HEADER}Checking dependencies...${COLOR_RESET}"
  command -v git >/dev/null 2>&1 || {
    echo >&2 "Git is not installed. Exiting..."
    exit 0
  }
  command -v mvn >/dev/null 2>&1 || {
    echo >&2 "Maven is not installed. Exiting..."
    exit 0
  }
  if [[ ${DOCKER} == true ]]; then
    command -v jq >/dev/null 2>&1 || {
      echo >&2 "Jq is not installed. Exiting..."
      exit 0
    }
    command -v docker >/dev/null 2>&1 || {
      echo >&2 "Docker is not installed. Exiting..."
      exit 0
    }
  fi
}

function update_tools() {
  echo -e "\n${COLOR_HEADER}Updating ${TOOLS}...${COLOR_RESET}"
  cd $TOOLS || {
    echo >&2 "${TOOLS} folder not found. Exiting..."
    exit 0
  }
  git pull
  cd ..
}

function clone_update_repositories() {
  IFS=';'
  for PROJECT in "${PROJECTS[@]}"; do
    read -ra PROJECT_AS_ARRAY <<<"$PROJECT"
    ABSOLUTE_PATH="$MAIN_DIR/${PROJECT_AS_ARRAY[0]}"
    if [[ ! -d "$ABSOLUTE_PATH" ]]; then
      echo -e "\n${COLOR_HEADER}Cloning ${PROJECT_AS_ARRAY[0]}...${COLOR_RESET}"
      git clone "${PROJECT_AS_ARRAY[1]}"
    elif [[ ${UPDATE} == true ]]; then
      echo -e "\n${COLOR_HEADER}Updating ${PROJECT_AS_ARRAY[0]}...${COLOR_RESET}"
      cd "${PROJECT_AS_ARRAY[0]}" || {
        echo >&2 "${PROJECT_AS_ARRAY[0]} folder not found. Exiting..."
        exit 0
      }
      git checkout master
      git pull
      cd ..
    fi
  done
  IFS=' '
}

function set_maven_profiles_active() {
  if [[ ${TESTS} == false && ${DOCKER} == false ]]; then
    MAVEN_PROFILES_ACTIVE="-Pfast"
  elif [[ ${TESTS} == false && ${DOCKER} == true ]]; then
    MAVEN_PROFILES_ACTIVE="-Pfast,docker"
  elif [[ ${TESTS} == true && ${DOCKER} == true ]]; then
    MAVEN_PROFILES_ACTIVE="-Pdocker"
  fi
}

function build_projects() {
  IFS=';'
  for PROJECT in "${PROJECTS[@]}"; do
    read -ra PROJECT_AS_ARRAY <<<"$PROJECT"
    if [[ "${PROJECT_AS_ARRAY[0]}" != "smart-ui"  ]] | [[ "${PROJECT_AS_ARRAY[0]}" != "smart-ui-angularjs"  ]]; then
      echo -e "\n${COLOR_HEADER}Building ${PROJECT_AS_ARRAY[0]}...${COLOR_RESET}"
      cd "$MAIN_DIR/${PROJECT_AS_ARRAY[0]}" || exit
      mvn clean install ${MAVEN_PROFILES_ACTIVE}
    elif [[ ${DOCKER} == true ]]; then
      echo -e "\n${COLOR_HEADER}Building ${PROJECT_AS_ARRAY[0]}...${COLOR_RESET}"
      cd "$MAIN_DIR/${PROJECT_AS_ARRAY[0]}" || exit
      docker build -t smart-ui:1.0.0 .
    fi
  done
  IFS=' '
}

function init() {
  START_TIME=$SECONDS
  check_dependencies
  update_tools
  clone_update_repositories
  set_maven_profiles_active
  build_projects
  ELAPSED_TIME=$(("$SECONDS" - "$START_TIME"))
  ((SEC = ELAPSED_TIME % 60, ELAPSED_TIME /= 60, MIN = ELAPSED_TIME % 60, HRS = ELAPSED_TIME / 60))
  TIMESTAMP=$(printf "%02d:%02d:%02d" ${HRS} ${MIN} ${SEC})
  echo -e "\n${COLOR_HEADER}Build script total time:${COLOR_RESET} ${TIMESTAMP}"
}

process_args "${@}"
init
