#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-015"
riskLevel="3"
diagnosisItem="API 사용에 대한 취약한 인증 모드 적용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-015"
diagnosisItem="API 사용에 대한 취약한 인증 모드 적용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'authorization-mode'가 webhook, RBAC 등으로 설정되어 있을 경우
[취약]: 'authorization-mode'가 존재하지 않거나, AlwaysAllow로 설정되어 있을 경우
EOF

BAR

# Function to check the authorization-mode setting
check_authorization_mode() {
    # Check the process for 'authorization-mode' setting
    authorization_mode=$(ps -ef | grep apiserver | grep -E "authorization-mode" | grep -v grep)

    # Check in various config files for the setting
    if grep -q "authorization-mode" "/etc/kubernetes/manifests/kube-apiserver.yaml"; then
        auth_mode_status="found"
    elif kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath="{range .items[]}{.spec.containers[].command} {''}{end}" | grep -E "authorization-mode"; then
        auth_mode_status="found"
    else
        auth_mode_status="not found"
    fi

    # Check if the authorization mode is 'AlwaysAllow'
    if [[ "$auth_mode_status" == "found" ]] && [[ "$authorization_mode" != "AlwaysAllow" ]]; then
        diagnosisResult="API 인증 모드가 양호"
        status="양호"
    else
        diagnosisResult="API 인증 모드가 취약"
        status="취약"
    fi

    # Output result for authorization-mode check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "API Authorization Mode: $diagnosisResult" >> $TMP1
}

# Run the check for authorization-mode
check_authorization_mode

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
