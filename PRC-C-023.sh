#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-023"
riskLevel="3"
diagnosisItem="Docker의 기본 네트워크 인터페이스(docker0) 사용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-023"
diagnosisItem="Docker의 기본 네트워크 인터페이스(docker0) 사용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: com.docker.network.bridge.default_bridge 값이 false인 경우
[취약]: com.docker.network.bridge.default_bridge 값이 true인 경우
EOF

BAR

# Function to check if Docker is using the default bridge network (docker0)
check_default_bridge_network() {
    docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}' | grep "com.docker.network.bridge.default_bridge" > $TMP1
    if [ $? -eq 0 ]; then
        bridge_value=$(docker network ls --quiet | xargs docker network inspect --format '{{ .Name }}: {{ .Options }}' | grep "com.docker.network.bridge.default_bridge" | awk -F ': ' '{print $2}' | sed 's/[",]//g')
        if [ "$bridge_value" == "false" ]; then
            diagnosisResult="docker0 사용 비활성화됨"
            status="양호"
        else
            diagnosisResult="docker0 사용 활성화됨"
            status="취약"
        fi
    else
        diagnosisResult="docker0 값 미설정"
        status="취약"
    fi

    # Output result for Default Bridge Network check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker Default Network (docker0): $diagnosisResult" >> $TMP1
}

# Run the check for Docker's default bridge network setting
check_default_bridge_network

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
