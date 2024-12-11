#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-038"
riskLevel="3"
diagnosisItem="마운트 전파 모드(Mount Propagation Mode) 공유 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-038"
diagnosisItem="마운트 전파 모드(Mount Propagation Mode) 공유 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'Propagation' 설정에 마운트 전파 모드가 'shared' 활성화되지 않은 경우
[취약]: 'Propagation' 설정에 마운트 전파 모드가 'shared' 활성화된 경우
EOF

BAR

# Function to check for "shared" mount propagation mode
check_mount_propagation() {
    # Retrieve the mount propagation setting for each container
    propagation=$(docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: Propagation={{range $mnt := .Mounts}} {{json $mnt.Propagation}} {{end}}')
    
    # Check each container's propagation setting
    while IFS= read -r line; do
        container_id=$(echo "$line" | cut -d':' -f1)
        container_propagation=$(echo "$line" | cut -d'=' -f2-)

        if [[ "$container_propagation" == *"shared"* ]]; then
            diagnosisResult="마운트 전파 모드에 'shared' 활성화됨: $container_propagation"
            status="취약"
        else
            diagnosisResult="마운트 전파 모드에 'shared' 없음."
            status="양호"
        fi

        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    done <<< "$propagation"
}

# Checking for 'shared' propagation mode in Docker containers
check_mount_propagation

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
