#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-014"
riskLevel="3"
diagnosisItem="API 요청 타임아웃 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-014"
diagnosisItem="API 요청 타임아웃 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'request-timeout'가 설정되어 있지 않거나, 60초 이하로 설정되어 있는 경우
[취약]: 'request-timeout'가 60초 초과로 설정되어 있는 경우
EOF

BAR

# Function to check the request-timeout setting
check_request_timeout() {
    # Check the process for 'request-timeout' setting
    request_timeout=$(ps -ef | grep apiserver | grep -E "request-timeout" | grep -v grep)

    # Check in various config files for the setting
    if grep -q "request-timeout" "/etc/kubernetes/manifests/kube-apiserver.yaml"; then
        timeout_status="found"
    elif kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath="{range .items[]}{.spec.containers[].command} {''}{end}" | grep -E "request-timeout"; then
        timeout_status="found"
    else
        timeout_status="not found"
    fi

    # Check if the request-timeout is greater than 60 seconds
    if [[ "$timeout_status" == "found" ]] && [[ "$request_timeout" -le 60 ]]; then
        diagnosisResult="API 요청 타임아웃이 양호"
        status="양호"
    else
        diagnosisResult="API 요청 타임아웃이 취약"
        status="취약"
    fi

    # Output result for request-timeout check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "API Request Timeout: $diagnosisResult" >> $TMP1
}

# Run the check for request-timeout
check_request_timeout

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
