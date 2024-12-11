#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-034"
riskLevel="2"
diagnosisItem="컨테이너 HEALTHCHECK"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-034"
diagnosisItem="컨테이너 HEALTHCHECK"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 이미지 내 또는 컨테이너 실행 명령줄에 HEALTHCHECK 명령어가 존재하는 경우
[취약]: 이미지 내 또는 컨테이너 실행 명령줄에 HEALTHCHECK 명령어가 존재하지 않는 경우
EOF

BAR

# Function to check if HEALTHCHECK is defined in the container image
check_healthcheck() {
    # Check for HEALTHCHECK in running containers
    containers=$(docker ps --quiet)

    # Iterate over containers
    for container in $containers; do
        health_status=$(docker inspect --format '{{.State.Health.Status}}' "$container")
        healthcheck_command=$(docker inspect --format '{{.Config.Healthcheck.Test}}' "$container")

        # Check for presence of HEALTHCHECK instruction
        if [[ -z "$healthcheck_command" ]]; then
            diagnosisResult="HEALTHCHECK 명령어가 존재하지 않음."
            status="취약"
        else
            diagnosisResult="HEALTHCHECK 명령어가 존재함."
            status="양호"
        fi

        # Output the result in CSV
        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

        # Output health status in log
        echo "Container $container: Health=$health_status" >> $TMP1
    done
}

# Checking for HEALTHCHECK
check_healthcheck

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
