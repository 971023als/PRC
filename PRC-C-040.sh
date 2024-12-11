#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-040"
riskLevel="3"
diagnosisItem="불필요한 AUFS 스토리지 드라이버 사용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-040"
diagnosisItem="불필요한 AUFS 스토리지 드라이버 사용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: AUFS 스토리지 드라이버를 사용하지 않을 경우
[취약]: AUFS 스토리지 드라이버를 사용하고 있을 경우
EOF

BAR

# Function to check AUFS usage in Containerd configuration
check_containerd_aufs() {
    if [ -f "/etc/containerd/config.toml" ]; then
        aufs_check=$(grep -i 'snapshotter' /etc/containerd/config.toml | grep -i 'aufs')
        if [ -n "$aufs_check" ]; then
            diagnosisResult="AUFS 스토리지 드라이버 사용됨."
            status="취약"
            echo "WARN: $diagnosisResult" >> $TMP1
        else
            diagnosisResult="AUFS 스토리지 드라이버 사용되지 않음."
            status="양호"
        fi
    else
        diagnosisResult="Containerd 설정 파일 없음."
        status="양호"
        echo "INFO: Containerd 설정 파일이 존재하지 않음." >> $TMP1
    fi
}

# Function to check AUFS usage in Docker configuration
check_docker_aufs() {
    storage_driver=$(docker info --format 'Storage Driver: {{ .Driver }}')

    if [[ "$storage_driver" == "Storage Driver: aufs" ]]; then
        diagnosisResult="AUFS 스토리지 드라이버 사용됨."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="AUFS 스토리지 드라이버 사용되지 않음."
        status="양호"
    fi
}

# Checking for AUFS usage in Docker and Containerd
check_containerd_aufs
check_docker_aufs

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
