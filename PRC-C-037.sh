#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-037"
riskLevel="3"
diagnosisItem="읽기 전용 모드로 컨테이너 루트 파일 시스템 마운트"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-037"
diagnosisItem="읽기 전용 모드로 컨테이너 루트 파일 시스템 마운트"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'ReadonlyRootfs'가 true로 설정되어 있을 경우
[취약]: 'ReadonlyRootfs'가 false로 설정되어 있을 경우
EOF

BAR

# Function to check if the container's root filesystem is in read-only mode
check_readonly_rootfs() {
    # Retrieve the ReadonlyRootfs setting for each container
    readonly_rootfs=$(docker ps --quiet --all | xargs docker inspect --format '{{ .Id }}: ReadonlyRootfs={{ .HostConfig.ReadonlyRootfs }}')
    
    # Check each container's ReadonlyRootfs setting
    while IFS= read -r line; do
        container_id=$(echo "$line" | cut -d':' -f1)
        readonly_rootfs_setting=$(echo "$line" | cut -d'=' -f2-)

        if [[ "$readonly_rootfs_setting" == "true" ]]; then
            diagnosisResult="컨테이너 루트 파일 시스템이 읽기 전용 모드로 설정됨."
            status="양호"
        else
            diagnosisResult="컨테이너 루트 파일 시스템이 읽기 전용 모드가 아님."
            status="취약"
        fi

        echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    done <<< "$readonly_rootfs"
}

# Checking for 'ReadonlyRootfs' in Docker containers
check_readonly_rootfs

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
