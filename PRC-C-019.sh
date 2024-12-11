#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-019"
riskLevel="4"
diagnosisItem="컨테이너 런타임 데몬의 관리자 권한 실행"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-019"
diagnosisItem="컨테이너 런타임 데몬의 관리자 권한 실행"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Docker 데몬이 관리자 권한으로 실행되지 않는 경우 (rootless 모드)
[취약]: Docker 데몬이 관리자 권한으로 실행되는 경우 (root 권한)
EOF

BAR

# Function to check if Docker daemon is running as root
check_docker_rootless() {
    # Check the user running the 'dockerd' process
    dockerd_user=$(ps -ef | grep 'dockerd' | grep -v grep | awk '{print $1}')
    if [ "$dockerd_user" == "root" ]; then
        diagnosisResult="Docker 데몬이 관리자 권한으로 실행됨"
        status="취약"
    else
        diagnosisResult="Docker 데몬이 관리자 권한으로 실행되지 않음"
        status="양호"
    fi

    # Output result for Docker daemon check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker Daemon Check: $diagnosisResult" >> $TMP1
}

# Run the check for Docker daemon user
check_docker_rootless

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
