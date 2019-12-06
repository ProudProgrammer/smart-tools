#!/bin/bash
#
# Starter script for Smart Platform

COLOR_HEADER="\033[7;49;36m"
COLOR_RESET="\033[0m"

LOGGING_FILTER="smart-logging-filter,https://github.com/ProudProgrammer/smart-logging-filter.git"
LOTTERY_SERVICE_CLIENT="smart-lottery-service-client,https://github.com/ProudProgrammer/smart-lottery-service-client.git"
LOTTERY_SERVICE="smart-lottery-service,https://github.com/ProudProgrammer/smart-lottery-service.git"
EDGE_SERVICE="smart-edge-service,https://github.com/ProudProgrammer/smart-edge-service.git"

PROJECTS=("$LOGGING_FILTER" "$LOTTERY_SERVICE_CLIENT" "$LOTTERY_SERVICE" "$EDGE_SERVICE")

cd ../../
MAIN_DIR=$(pwd)

function clone() {
  IFS=','
  for PROJECT in "${PROJECTS[@]}"
  do
    read -ra PROJECT_AS_ARRAY <<< "$PROJECT"
    ABSOLUTE_PATH="$MAIN_DIR/${PROJECT_AS_ARRAY[0]}"
    if [ ! -d "$ABSOLUTE_PATH" ]; then
      echo -e "\n$COLOR_HEADER Cloning ${PROJECT_AS_ARRAY[0]}...$COLOR_RESET"
      git clone "${PROJECT_AS_ARRAY[1]}"
    fi
  done
  IFS=' '
}

function build() {
  IFS=','
	for PROJECT in "${PROJECTS[@]}"
	do
	  read -ra PROJECT_AS_ARRAY <<< "$PROJECT"
		echo -e "\n$COLOR_HEADER Building ${PROJECT_AS_ARRAY[0]}... $COLOR_RESET"
		cd "$MAIN_DIR/${PROJECT_AS_ARRAY[0]}" || exit
		mvn clean install
	done
	IFS=' '
}

clone
build