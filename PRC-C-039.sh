#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-039"
riskLevel="3"
diagnosisItem="컨테이너의 불필요한 외부 장치 연결"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-039"
diagnosisItem="컨테이너의 불필요한 외부 장치 연결"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'HostConfig.Devices'에 불필요한 장치가 마운트되어 있지 않을 경우
[취약]: 'HostConfig.Devices'에 불필요한 장치가 마운트되어 있을 경우
EOF

BAR

# Function to check for unnecessary devices in Docker container
check_docker_devices() {
    # Retrieve the devices mounted to each container
    devices=$(docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Devices={{ .HostConfig.Devices }}')
    
    # Check each container's devices
    while IFS= read -r line; do
        container_id=$(echo "$line" | cut -d':' -f1)
        container_devices=$(echo "$line" | cut -d'=' -f2-)

        if [[ "$container_devices" == "Devices=[]" ]]; then
            diagnosisResult="불필요한 장치 없음."
            status="양호"
        else
            diagnosisResult="불필요한 장치가 마운트됨: $container_devices"
            status="취약"
        fi

        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    done <<< "$devices"
}

# Checking for unnecessary devices in Docker containers
check_docker_devices

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
