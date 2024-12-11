#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-011"
riskLevel="3"
diagnosisItem="원격 로그 서버 이용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-011"
diagnosisItem="원격 로그 서버 이용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 원격 로그 서버를 위한 Log Driver 설정이 적절하게 구성되어 있을 경우
[취약]: json-file로 설정되어 있고, 원격 로그 저장이 이루어지지 않는 경우 또는 관련 서비스 설정이 누락된 경우
EOF

BAR

# Function to check Docker log driver configuration
check_log_driver_configuration() {
    # Check log-driver in the Docker daemon process
    log_driver=$(ps -ef | grep 'dockerd' | grep -e "log-driver" | grep -v grep)
    if [[ ! -z "$log_driver" ]]; then
        if [[ "$log_driver" =~ "log-driver=json-file" ]]; then
            diagnosisResult="로그가 로컬 파일에 저장되고 있음 (json-file 설정)"
            status="취약"
        elif [[ "$log_driver" =~ "log-driver=fluentd" || "$log_driver" =~ "log-driver=syslog" || "$log_driver" =~ "log-driver=awslogs" ]]; then
            diagnosisResult="원격 로그 서버로 로그가 전송되고 있음"
            status="양호"
        else
            diagnosisResult="로그 전송 설정 없음"
            status="취약"
        fi
    else
        diagnosisResult="Docker 데몬에서 로그 전송 설정을 찾을 수 없음"
        status="취약"
    fi

    # Check for Docker log driver via docker info
    docker_log_driver=$(docker info --format '{{ .LoggingDriver }}')
    if [[ "$docker_log_driver" == "json-file" ]]; then
        diagnosisResult="로그가 로컬 파일에 저장되고 있음 (json-file 설정)"
        status="취약"
    elif [[ "$docker_log_driver" == "fluentd" || "$docker_log_driver" == "syslog" || "$docker_log_driver" == "awslogs" ]]; then
        diagnosisResult="원격 로그 서버로 로그가 전송되고 있음"
        status="양호"
    fi

    # Output the result to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "로그 드라이버 설정 확인: $diagnosisResult" >> $TMP1
}

# Run the check for log driver configuration
check_log_driver_configuration

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
