#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-050"
riskLevel="2"
diagnosisItem="Ulimit 구성의 적절성"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-050"
diagnosisItem="Docker 데몬의 default-ulimit 옵션 및 개별 컨테이너 ulimit 설정 점검"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Docker 데몬에 'default-ulimit' 옵션이 존재하거나, 개별 컨테이너에 'ulimit' 옵션이 설정되어 있는 경우
[취약]: Docker 데몬에 'default-ulimit' 옵션이 존재하지 않거나, 개별 컨테이너에 'ulimit' 옵션이 설정되지 않은 경우
EOF

BAR

# Function to check Docker daemon default-ulimit settings
check_docker_ulimit() {
    local ulimit_check=""
    local daemon_ulimit=""

    # Check Docker daemon for default-ulimit parameter
    daemon_ulimit=$(ps -ef | grep 'dockerd' | grep 'default-ulimit' | grep -v grep)

    if [ ! -z "$daemon_ulimit" ]; then
        # Daemon configuration is found with default-ulimit
        diagnosisResult="Docker 데몬에 'default-ulimit' 옵션이 설정되어 있습니다."
        status="양호"
    else
        # Check for ulimit configuration in container
        diagnosisResult="Docker 데몬에 'default-ulimit' 옵션이 설정되어 있지 않습니다. 개별 컨테이너에서 ulimit 설정을 확인해야 합니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi

    # Output to CSV
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check individual container ulimit settings
check_container_ulimit() {
    local container_id=$1
    local container_ulimit=""

    # Check if ulimit is set for the container
    container_ulimit=$(docker inspect --format '{{.HostConfig.Ulimits}}' $container_id)

    if [ ! -z "$container_ulimit" ]; then
        diagnosisResult="컨테이너 $container_id에 ulimit 설정이 존재합니다."
        status="양호"
    else
        diagnosisResult="컨테이너 $container_id에 ulimit 설정이 존재하지 않습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi

    # Output to CSV
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Check Docker daemon for ulimit settings
check_docker_ulimit

# Replace with actual container IDs to check individual containers
container_ids=("container1" "container2")

for container_id in "${container_ids[@]}"; do
    check_container_ulimit $container_id
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
