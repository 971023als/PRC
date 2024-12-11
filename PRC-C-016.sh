#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-016"
riskLevel="3"
diagnosisItem="API 사용시 서비스 계정 토큰 검증 여부"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-016"
diagnosisItem="API 사용시 서비스 계정 토큰 검증 여부"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'service-account-lookup'가 true로 설정되어 있거나, 존재하지 않을 경우
[취약]: 'service-account-lookup'가 false로 설정되어 있을 경우
EOF

BAR

# Function to check the service-account-lookup setting
check_service_account_lookup() {
    # Check the process for 'service-account-lookup' setting
    service_account_lookup=$(ps -ef | grep apiserver | grep -E "service-account-lookup" | grep -v grep)
    
    # Check in various config files for the setting
    if grep -q "service-account-lookup" "/etc/kubernetes/manifests/kube-apiserver.yaml"; then
        service_account_status="found"
    elif kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath="{range .items[]}{.spec.containers[].command} {''}{end}" | grep -E "service-account-lookup"; then
        service_account_status="found"
    else
        service_account_status="not found"
    fi

    # Check if the setting is true
    if [[ "$service_account_status" == "found" ]] && [[ "$service_account_lookup" != "false" ]]; then
        diagnosisResult="서비스 계정 토큰 검증이 양호"
        status="양호"
    else
        diagnosisResult="서비스 계정 토큰 검증이 취약"
        status="취약"
    fi

    # Output result for service-account-lookup check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "API Service Account Token Validation: $diagnosisResult" >> $TMP1
}

# Run the check for service-account-lookup
check_service_account_lookup

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
