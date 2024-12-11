#!/bin/bash

# Output file for the results
OUTPUT_CSV="output_default_service_account_usage.csv"
TMP1=$(basename "$0").log

# Define the category and other fields for CSV output
category="기술적 보안"
code="PRC-C-003"
riskLevel="4"
diagnosisItem="기본 서비스 계정 사용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

# Create CSV header if it does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Function to check for default service account usage in non-system namespaces
check_default_service_account_usage() {
    echo "Checking for default service account usage in non-system namespaces..."

    # Check all pods in all namespaces for the service account being used
    kubectl get pods -A -o=jsonpath='{range .items[*]}{.metadata.name}:{.metadata.namespace}:{.spec.serviceAccountName}{"\n"}{end}' > $TMP1

    # Search for pods using the default service account
    default_service_account_usage=$(grep ":default$" $TMP1)

    if [ -n "$default_service_account_usage" ]; then
        diagnosisResult="POD가 기본 서비스 계정(default)을 사용하고 있음"
        status="취약"
    else
        diagnosisResult="POD가 기본 서비스 계정(default)을 사용하지 않음"
        status="양호"
    fi
    
    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "POD Default Service Account Usage: $diagnosisResult" >> $TMP1
}

# Check default service account usage
check_default_service_account_usage

# Output the detailed results to the terminal
cat $TMP1

# Output the CSV file contents
echo ; echo
cat $OUTPUT_CSV
