#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-013"
riskLevel="3"
diagnosisItem="Anonymous 계정의 API 접속 제한 미비"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-013"
diagnosisItem="Anonymous 계정의 API 접속 제한 미비"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'anonymous-auth'가 false로 설정되어 있을 경우
[취약]: 'anonymous-auth'가 존재하지 않거나, true로 설정되어 있을 경우
EOF

BAR

# Function to check the anonymous-auth setting
check_anonymous_auth() {
    # Check the process for 'anonymous-auth' setting
    anonymous_auth=$(ps -ef | grep apiserver | grep -E "anonymous-auth" | grep -v grep)

    # Check in various config files for the setting
    if grep -q "anonymous-auth" "/etc/kubernetes/manifests/kube-apiserver.yaml"; then
        auth_status="found"
    elif kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath="{range .items[]}{.spec.containers[].command} {''}{end}" | grep -E "anonymous-auth"; then
        auth_status="found"
    else
        auth_status="not found"
    fi

    # Check if anonymous-auth is set to false
    if [[ "$auth_status" == "found" ]] && [[ "$anonymous_auth" =~ "false" ]]; then
        diagnosisResult="Anonymous 계정 API 접속이 양호"
        status="양호"
    else
        diagnosisResult="Anonymous 계정 API 접속이 취약"
        status="취약"
    fi

    # Output result for anonymous-auth check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Anonymous Auth: $diagnosisResult" >> $TMP1
}

# Run the check for anonymous-auth
check_anonymous_auth

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
