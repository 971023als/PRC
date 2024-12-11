#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-020"
riskLevel="3"
diagnosisItem="실험적 기능 비활성화"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-020"
diagnosisItem="실험적 기능 비활성화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 실험적 기능이 비활성화 되어 있는 경우 (false)
[취약]: 실험적 기능이 활성화 되어 있는 경우 (true)
EOF

BAR

# Function to check if experimental features are enabled in Docker
check_experimental_feature() {
    # Check using Docker info command
    docker_info_output=$(docker info --format '{{ .Server.Experimental }}')
    if [ "$docker_info_output" == "true" ]; then
        diagnosisResult="실험적 기능 활성화됨: $docker_info_output"
        status="취약"
    else
        # Check in the Docker configuration file for 'experimental' setting
        sudo cat /etc/docker/daemon.json | grep "experimental" > $TMP1
        if [ $? -eq 0 ]; then
            experimental_value=$(sudo cat /etc/docker/daemon.json | grep "experimental" | awk -F ': ' '{print $2}' | sed 's/[",]//g')
            if [ "$experimental_value" == "true" ]; then
                diagnosisResult="실험적 기능 활성화됨: $experimental_value"
                status="취약"
            else
                diagnosisResult="실험적 기능 비활성화됨"
                status="양호"
            fi
        else
            diagnosisResult="실험적 기능 설정 없음"
            status="양호"
        fi
    fi

    # Output result for experimental feature check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Experimental Feature Check: $diagnosisResult" >> $TMP1
}

# Run the check for experimental feature status
check_experimental_feature

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
