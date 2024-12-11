#!/bin/bash

# Output file for the results
OUTPUT_CSV="output_service_account_credentials.csv"
TMP1=$(basename "$0").log

# Define the category and other fields for CSV output
category="기술적 보안"
code="PRC-C-005"
riskLevel="3"
diagnosisItem="컨트롤러 별 서비스 계정 자격 증명 사용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

# Create CSV header if it does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Function to check if use-service-account-credentials is enabled
check_use_service_account_credentials() {
    echo "Checking use-service-account-credentials setting in kube-controller-manager..."

    # Check the kube-controller-manager process for use-service-account-credentials
    controller_setting=$(ps -ef | grep controller-manager | grep -E 'use-service-account-credentials' | grep -v grep)
    
    if [ -n "$controller_setting" ]; then
        diagnosisResult="'use-service-account-credentials'가 true로 설정됨"
        status="양호"
    else
        diagnosisResult="'use-service-account-credentials'가 false로 설정됨"
        status="취약"
    fi
    
    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "'use-service-account-credentials' Setting: $diagnosisResult" >> $TMP1
}

# Function to check controller-manager YAML configuration for use-service-account-credentials
check_controller_manager_config() {
    echo "Checking kube-controller-manager.yaml for use-service-account-credentials..."

    # Check the kube-controller-manager YAML for use-service-account-credentials setting
    yaml_setting=$(grep -E "use-service-account-credentials" "/etc/kubernetes/manifests/kube-controller-manager.yaml")
    
    if [ -n "$yaml_setting" ]; then
        diagnosisResult="'use-service-account-credentials'가 true로 설정됨"
        status="양호"
    else
        diagnosisResult="'use-service-account-credentials'가 false로 설정됨"
        status="취약"
    fi
    
    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "kube-controller-manager.yaml Setting: $diagnosisResult" >> $TMP1
}

# Check use-service-account-credentials in controller-manager process
check_use_service_account_credentials

# Check use-service-account-credentials in kube-controller-manager.yaml
check_controller_manager_config

# Output the detailed results to the terminal
cat $TMP1

# Output the CSV file contents
echo ; echo
cat $OUTPUT_CSV
