#!/bin/bash

# Output file for the results
OUTPUT_CSV="output_vulnerable_token_auth.csv"
TMP1=$(basename "$0").log

# Define the category and other fields for CSV output
category="기술적 보안"
code="PRC-C-004"
riskLevel="5"
diagnosisItem="취약한 인증 방식 사용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

# Create CSV header if it does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

# Function to check for vulnerable token-auth-file setting in apiserver
check_token_auth_file() {
    echo "Checking token-auth-file setting in kube-apiserver..."

    # Check the kube-apiserver process for token-auth-file
    token_auth_file_setting=$(ps -ef | grep apiserver | grep -E 'token-auth-file' | grep -v grep)
    
    if [ -n "$token_auth_file_setting" ]; then
        diagnosisResult="'token-auth-file'에 매핑된 token 경로가 존재"
        status="취약"
    else
        diagnosisResult="'token-auth-file'에 매핑된 token 경로가 존재하지 않음"
        status="양호"
    fi
    
    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "API Server Setting: $diagnosisResult" >> $TMP1
}

# Function to check for token-auth-file in kube-apiserver.yaml
check_token_auth_file_in_yaml() {
    echo "Checking kube-apiserver.yaml for token-auth-file..."

    # Check the kube-apiserver YAML configuration for token-auth-file setting
    yaml_setting=$(grep -E "token-auth-file" "/etc/kubernetes/manifests/kube-apiserver.yaml")
    
    if [ -n "$yaml_setting" ]; then
        diagnosisResult="'token-auth-file'에 매핑된 token 경로가 존재"
        status="취약"
    else
        diagnosisResult="'token-auth-file'에 매핑된 token 경로가 존재하지 않음"
        status="양호"
    fi
    
    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "kube-apiserver.yaml Setting: $diagnosisResult" >> $TMP1
}

# Function to check token-auth-file in kube-apiserver pods
check_token_auth_file_in_pods() {
    echo "Checking kube-apiserver pods for token-auth-file..."

    # Check if the token-auth-file is used in any kube-apiserver pod command
    pod_setting=$(kubectl get pods -n kube-system -l component=kube-apiserver -o jsonpath="{range .items[]}{.spec.containers[].command}{' '}{end}" | grep -E "token-auth-file")
    
    if [ -n "$pod_setting" ]; then
        diagnosisResult="'token-auth-file'에 매핑된 token 경로가 존재"
        status="취약"
    else
        diagnosisResult="'token-auth-file'에 매핑된 token 경로가 존재하지 않음"
        status="양호"
    fi
    
    # Log the result
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "kube-apiserver Pods Setting: $diagnosisResult" >> $TMP1
}

# Check token-auth-file in API server process
check_token_auth_file

# Check token-auth-file in kube-apiserver.yaml
check_token_auth_file_in_yaml

# Check token-auth-file in kube-apiserver pods
check_token_auth_file_in_pods

# Output the detailed results to the terminal
cat $TMP1

# Output the CSV file contents
echo ; echo
cat $OUTPUT_CSV
