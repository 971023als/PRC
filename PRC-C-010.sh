#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-010"
riskLevel="3"
diagnosisItem="휘발성 경로 내 로그 파일 저장 여부 확인"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-010"
diagnosisItem="휘발성 경로 내 로그 파일 저장 여부 확인"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 로그 파일이 비휘발성 경로에 저장되고 있는 경우
[취약]: 로그 파일이 휘발성 경로에 저장되는 경우 또는 설정이 없는 경우
EOF

BAR

# Function to check log file locations for kube-apiserver
check_kube_apiserver_log_location() {
    # Check if audit-log-path is configured for kube-apiserver
    audit_log_path=$(ps -ef | grep apiserver | grep -E "audit-log-path" | grep -v grep)
    if [[ ! -z "$audit_log_path" ]]; then
        if [[ "$audit_log_path" =~ "/tmp|/var/tmp|/run|/dev/shm|/dev/pts" ]]; then
            diagnosisResult="로그가 휘발성 경로에 저장되고 있음"
            status="취약"
        else
            diagnosisResult="로그가 비휘발성 경로에 저장되고 있음"
            status="양호"
        fi
    else
        diagnosisResult="audit-log-path 설정이 없음"
        status="취약"
    fi

    # Output result for kube-apiserver log file location
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kube-apiserver 로그 경로 설정 확인: $diagnosisResult" >> $TMP1
}

# Function to check log file locations for kubelet
check_kubelet_log_location() {
    # Check if log-file is configured for kubelet
    kubelet_log_path=$(ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern="--log-file")
    if [[ ! -z "$kubelet_log_path" ]]; then
        if [[ "$kubelet_log_path" =~ "/tmp|/var/tmp|/run|/dev/shm|/dev/pts" ]]; then
            diagnosisResult="로그가 휘발성 경로에 저장되고 있음"
            status="취약"
        else
            diagnosisResult="로그가 비휘발성 경로에 저장되고 있음"
            status="양호"
        fi
    else
        diagnosisResult="log-file 설정이 없음"
        status="취약"
    fi

    # Output result for kubelet log file location
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kubelet 로그 경로 설정 확인: $diagnosisResult" >> $TMP1
}

# Run checks for both kube-apiserver and kubelet log locations
check_kube_apiserver_log_location
check_kubelet_log_location

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
