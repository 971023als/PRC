#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-032"
riskLevel="2"
diagnosisItem="컨테이너의 상태 보존 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-032"
diagnosisItem="컨테이너의 상태 보존 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'Live Restore' 옵션이 활성화 되어 있는 경우
[취약]: 'Live Restore' 옵션이 비활성화 되어 있는 경우
EOF

BAR

# Function to check if LiveRestore option is enabled for Docker daemon
check_live_restore() {
    # Method 1: Check if 'live-restore' argument is present in 'dockerd' process
    live_restore_process=$(ps -ef | grep 'dockerd' | grep 'live-restore' | grep -v grep)

    if [ -n "$live_restore_process" ]; then
        diagnosisResult="Live Restore 설정이 존재"
        status="양호"
    else
        diagnosisResult="Live Restore 설정이 존재하지 않음"
        status="취약"
    fi

    # Output result to CSV
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

    # Log the result
    echo "Live Restore check: $diagnosisResult" >> $TMP1
}

# Function to check LiveRestoreEnabled value from 'docker info'
check_docker_info() {
    live_restore_info=$(docker info --format '{{ .LiveRestoreEnabled }}')

    if [ "$live_restore_info" == "true" ]; then
        diagnosisResult="Live Restore 설정이 존재"
        status="양호"
    else
        diagnosisResult="Live Restore 설정이 존재하지 않음"
        status="취약"
    fi

    # Output result to CSV
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

    # Log the result
    echo "Live Restore check from docker info: $diagnosisResult" >> $TMP1
}

# Run the checks
check_live_restore
check_docker_info

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
