#!/bin/bash
#
# Stopper script for Smart Platform

COLOR_HEADER="\033[7;49;36m"
COLOR_RESET="\033[0m"

function print_help() {
  echo "Usage: ./stop.sh"
  echo "Options:"
  echo "    -h, --h         print help"
  echo ""
  echo "Automation script for Smart-Platform."
  echo "It can stop containers."
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
  command -v docker >/dev/null 2>&1 || {
    echo >&2 "Docker is not installed. Exiting..."
    exit 0
  }
}

function stop_containers() {
  echo -e "\n${COLOR_HEADER}Stopping docker containers...${COLOR_RESET}"
  docker container stop $(docker ps | grep "[edge|lottery]" | awk '{ print $1 }')
}

function init() {
  START_TIME=$SECONDS
  check_dependencies
  stop_containers
  ELAPSED_TIME=$(("$SECONDS" - "$START_TIME"))
  ((SEC = ELAPSED_TIME % 60, ELAPSED_TIME /= 60, MIN = ELAPSED_TIME % 60, HRS = ELAPSED_TIME / 60))
  TIMESTAMP=$(printf "%02d:%02d:%02d" ${HRS} ${MIN} ${SEC})
  echo -e "\n${COLOR_HEADER}Stop script total time:${COLOR_RESET} ${TIMESTAMP}"
}

process_args "${@}"
init
