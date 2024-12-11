#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-009"
riskLevel="3"
diagnosisItem="시스템 주요 이벤트 로그 설정 미흡"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-009"
diagnosisItem="시스템 주요 이벤트 로그 설정 미흡"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 시스템 주요 이벤트 로그 설정이 되어 있는 경우
[취약]: 시스템 주요 이벤트 로그 설정이 되어 있지 않거나 설정이 부족한 경우
EOF

BAR

# Function to check audit-log-path for kube-apiserver
check_kube_apiserver_audit_log() {
    # Check if audit-log-path is configured for kube-apiserver
    audit_log_path=$(ps -ef | grep apiserver | grep -E "audit-log-path" | grep -v grep)
    if [[ ! -z "$audit_log_path" ]]; then
        diagnosisResult="audit-log-path 설정이 있음"
        status="양호"
    else
        diagnosisResult="audit-log-path 설정이 없음"
        status="취약"
    fi

    # Output result for kube-apiserver audit log
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kube-apiserver 감사 로그 경로 설정 확인: $diagnosisResult" >> $TMP1
}

# Function to check audit-policy-file for kube-apiserver
check_kube_apiserver_audit_policy() {
    # Check if audit-policy-file is configured for kube-apiserver
    audit_policy_file=$(ps -ef | grep apiserver | grep -E "audit-policy-file" | grep -v grep)
    if [[ ! -z "$audit_policy_file" ]]; then
        diagnosisResult="audit-policy-file 설정이 있음"
        status="양호"
    else
        diagnosisResult="audit-policy-file 설정이 없음"
        status="취약"
    fi

    # Output result for kube-apiserver audit policy
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kube-apiserver 감사 로그 정책 설정 확인: $diagnosisResult" >> $TMP1
}

# Function to check log level for kubelet
check_kubelet_log_level() {
    # Check if log level is configured for kubelet (v flag for verbosity)
    kubelet_log_level=$(ps -ef | grep kubelet | grep -v 'grep' | awk -v pattern="--v")
    if [[ ! -z "$kubelet_log_level" ]]; then
        if [[ "$kubelet_log_level" =~ "--v=3" || "$kubelet_log_level" =~ "--v=4" || "$kubelet_log_level" =~ "--v=5" ]]; then
            diagnosisResult="v 플래그가 3 이상으로 설정됨"
            status="양호"
        else
            diagnosisResult="v 플래그가 3 미만으로 설정됨"
            status="취약"
        fi
    else
        diagnosisResult="v 플래그 설정이 없음"
        status="취약"
    fi

    # Output result for kubelet log level
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Kubelet 로그 수준(v 플래그) 설정 확인: $diagnosisResult" >> $TMP1
}

# Function to check log-level for dockerd
check_docker_log_level() {
    # Check if log-level is configured for Docker daemon
    docker_log_level=$(ps -ef | grep 'dockerd' | grep "log-level" | grep -v grep)
    if [[ ! -z "$docker_log_level" ]]; then
        diagnosisResult="log-level 설정이 있음"
        status="양호"
    else
        diagnosisResult="log-level 설정이 없음"
        status="취약"
    fi

    # Output result for Docker log level
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker 로그 수준 설정 확인: $diagnosisResult" >> $TMP1
}

# Function to check if Docker daemon.json file contains log-level
check_docker_daemon_config() {
    docker_config_log_level=$(sudo cat /etc/docker/daemon.json | grep "log-level")
    if [[ ! -z "$docker_config_log_level" ]]; then
        diagnosisResult="daemon.json 파일에 log-level 설정이 있음"
        status="양호"
    else
        diagnosisResult="daemon.json 파일에 log-level 설정이 없음"
        status="취약"
    fi

    # Output result for Docker daemon.json log level
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker 설정 파일에서 log-level 설정 확인: $diagnosisResult" >> $TMP1
}

# Run checks for kube-apiserver audit-log-path, audit-policy-file, kubelet log-level, and docker log-level
check_kube_apiserver_audit_log
check_kube_apiserver_audit_policy
check_kubelet_log_level
check_docker_log_level
check_docker_daemon_config

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
