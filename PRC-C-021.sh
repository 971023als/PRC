#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-021"
riskLevel="3"
diagnosisItem="데몬의 사용자 영역(userland) 프록시 사용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-021"
diagnosisItem="데몬의 사용자 영역(userland) 프록시 사용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: Userland Proxy가 비활성화된 경우 (false)
[취약]: Userland Proxy가 활성화된 경우 (true) 또는 설정되지 않은 경우
EOF

BAR

# Function to check if Docker is using userland proxy
check_userland_proxy() {
    # Check if the docker daemon is using userland proxy (via dockerd command line)
    ps -ef | grep 'dockerd' | grep -- 'userland-proxy' > $TMP1
    if [ $? -eq 0 ]; then
        userland_proxy=$(ps -ef | grep 'dockerd' | grep 'userland-proxy' | awk -F '--userland-proxy=' '{print $2}' | sed 's/^[[:space:]]*//')
        diagnosisResult="Userland Proxy 사용됨: $userland_proxy"
        status="취약"
    else
        # Check docker configuration file for userland-proxy setting
        sudo cat /etc/docker/daemon.json | grep "userland-proxy" > $TMP1
        if [ $? -eq 0 ]; then
            userland_proxy=$(sudo cat /etc/docker/daemon.json | grep "userland-proxy" | awk -F ': ' '{print $2}' | sed 's/[",]//g')
            diagnosisResult="Userland Proxy 사용됨: $userland_proxy"
            status="취약"
        else
            diagnosisResult="Userland Proxy 설정 없음"
            status="양호"
        fi
    fi

    # Output result for Userland Proxy check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Userland Proxy Check: $diagnosisResult" >> $TMP1
}

# Run the check for userland proxy usage
check_userland_proxy

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
