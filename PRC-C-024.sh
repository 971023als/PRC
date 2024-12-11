#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-024"
riskLevel="3"
diagnosisItem="Default Network Bridge 내 네트워크 트래픽 제한 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-024"
diagnosisItem="Default Network Bridge 내 네트워크 트래픽 제한 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: icc 값이 false로 설정된 경우
[취약]: icc 값이 설정되지 않았거나 true로 설정된 경우
EOF

BAR

# Function to check if ICC is disabled in Docker daemon
check_docker_daemon() {
    ps -ef | grep 'dockerd' | grep 'icc' | grep -v grep > $TMP1
    if [ $? -eq 0 ]; then
        diagnosisResult="icc 기능 비활성화됨"
        status="양호"
    else
        diagnosisResult="icc 기능 활성화됨"
        status="취약"
    fi

    # Output result for Docker Daemon
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker Daemon: $diagnosisResult" >> $TMP1
}

# Function to check ICC setting in Docker configuration file
check_docker_config() {
    sudo cat /etc/docker/daemon.json | grep "icc" > $TMP1
    if [ $? -eq 0 ]; then
        icc_value=$(sudo cat /etc/docker/daemon.json | grep "icc" | awk -F ': ' '{print $2}' | sed 's/[",]//g')
        if [ "$icc_value" == "false" ]; then
            diagnosisResult="icc 기능 비활성화됨"
            status="양호"
        else
            diagnosisResult="icc 기능 활성화됨"
            status="취약"
        fi
    else
        diagnosisResult="icc 값 미설정"
        status="취약"
    fi

    # Output result for Docker Configuration
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker Config (daemon.json): $diagnosisResult" >> $TMP1
}

# Function to check ICC setting in Docker networks
check_docker_networks() {
    docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}' | grep "com.docker.network.bridge.enable_icc" > $TMP1
    if [ $? -eq 0 ]; then
        icc_value=$(docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}' | grep "com.docker.network.bridge.enable_icc" | awk -F ': ' '{print $2}' | sed 's/[",]//g')
        if [ "$icc_value" == "false" ]; then
            diagnosisResult="icc 기능 비활성화됨"
            status="양호"
        else
            diagnosisResult="icc 기능 활성화됨"
            status="취약"
        fi
    else
        diagnosisResult="icc 값 미설정"
        status="취약"
    fi

    # Output result for Docker Networks
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker Networks: $diagnosisResult" >> $TMP1
}

# Run all checks
check_docker_daemon
check_docker_config
check_docker_networks

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
