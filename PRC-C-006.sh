#!/bin/bash

# Output file for the results
OUTPUT_CSV="output_service_account_token_expiry.csv"
TMP1=$(basename "$0").log

# Define the category and other fields for CSV output
category="기술적 보안"
code="PRC-C-006"
riskLevel="3"
diagnosisItem="서비스 계정 토큰 수명 제한 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

# Create CSV header if it does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Function to check BoundServiceAccountTokenVolume
check_bound_service_account_token_volume() {
    echo "Checking BoundServiceAccountTokenVolume setting..."
    
    # Check if BoundServiceAccountTokenVolume is enabled in the kube-apiserver
    bound_setting=$(ps -ef | grep apiserver | grep -E 'BoundServiceAccountTokenVolume' | grep -v grep)
    
    if [ -n "$bound_setting" ]; then
        diagnosisResult="BoundServiceAccountTokenVolume 활성화"
        status="양호"
    else
        diagnosisResult="BoundServiceAccountTokenVolume 비활성화"
        status="취약"
    fi
    
    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "BoundServiceAccountTokenVolume: $diagnosisResult" >> $TMP1
}

# Function to check service account token expiration
check_token_expiry() {
    echo "Checking service account token expiration..."

    # Check the expiration timestamp for service accounts
    token_expiry_info=$(kubectl get serviceaccount --all-namespaces -o=jsonpath="{range .items[*]}{'Namespace: '}{.metadata.namespace}|{.metadata.name}|{'Tokens Expiry: '}{range .secrets[*]}{.expirationTimestamp}{' '}{end}{'\n'}{end}")
    
    # Check if token expiration is set
    if [ -z "$token_expiry_info" ]; then
        diagnosisResult="서비스 계정 토큰 만료 기간 미설정"
        status="취약"
    else
        diagnosisResult="서비스 계정 토큰 만료 기간 설정됨"
        status="양호"
    fi
    
    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Service Account Token Expiry: $diagnosisResult" >> $TMP1
}

# Check BoundServiceAccountTokenVolume
check_bound_service_account_token_volume

# Check service account token expiration
check_token_expiry

# Output the detailed results to the terminal
cat $TMP1

# Output the CSV file contents
echo ; echo
cat $OUTPUT_CSV
