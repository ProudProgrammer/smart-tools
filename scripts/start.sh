#!/bin/bash
#
# Starter script for Smart Platform

COLOR_HEADER="\033[7;49;36m"
COLOR_RESET="\033[0m"

LOGGING_FILTER_DIR="smart-logging-filter"
LOTTERY_SERVICE_CLIENT_DIR="smart-lottery-service-client"
LOTTERY_SERVICE_DIR="smart-lottery-service"
EDGE_SERVICE_DIR="smart-edge-service"

PROJECT_DIRS=(${LOGGING_FILTER_DIR} ${LOTTERY_SERVICE_CLIENT_DIR} ${LOTTERY_SERVICE_DIR} ${EDGE_SERVICE_DIR})

cd ../../
MAIN_DIR=$(pwd)

function build() {
	for PROJECT_DIR in ${PROJECT_DIRS[@]}
	do
		echo -e "\n$COLOR_HEADER Building ${PROJECT_DIR}... $COLOR_RESET"
		cd "$MAIN_DIR/$PROJECT_DIR"
		mvn clean install
	done
}

build