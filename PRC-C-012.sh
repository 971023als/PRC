#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-012"
riskLevel="3"
diagnosisItem="API 통신에 대한 보안 프로토콜 사용"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-012"
diagnosisItem="API 통신에 대한 보안 프로토콜 사용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'tls-cert-file', 'tls-private-key-file' 설정이 되어 있을 경우
[취약]: 'tls-cert-file', 'tls-private-key-file' 설정이 되어 있지 않은 경우
EOF

BAR

# Function to check the TLS certificate and key settings
check_tls_configuration() {
    # Check for TLS settings in API server configuration
    tls_cert_key_api=$(ps -ef | grep apiserver | grep -E "tls-cert-file|tls-private-key-file" | grep -v grep)
    if [[ ! -z "$tls_cert_key_api" ]]; then
        diagnosisResult="API 서버에 TLS 설정이 되어 있음"
        status="양호"
    else
        diagnosisResult="API 서버에 TLS 설정이 되어 있지 않음"
        status="취약"
    fi

    # Check in kube-apiserver manifest
    if grep -E "tls-cert-file|tls-private-key-file" "/etc/kubernetes/manifests/kube-apiserver.yaml" > /dev/null; then
        diagnosisResult="API 서버에 TLS 설정이 되어 있음"
        status="양호"
    fi

    # Check Kubelet settings for TLS
    tls_cert_key_kubelet=$(ps -ef | grep kubelet | grep -v grep | grep -E "tls-cert-file|tls-private-key-file")
    if [[ ! -z "$tls_cert_key_kubelet" ]]; then
        diagnosisResult="Kubelet에 TLS 설정이 되어 있음"
        status="양호"
    else
        diagnosisResult="Kubelet에 TLS 설정이 되어 있지 않음"
        status="취약"
    fi

    # Output result for TLS configuration check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "TLS 설정 확인: $diagnosisResult" >> $TMP1
}

# Function to check Docker API TLS configuration (if applicable)
check_docker_tls_configuration() {
    # Check if Docker is using TLS
    docker_tls_check=$(ps -ef | grep 'dockerd' | grep -E "tlsverify|tlscacert|tlscert|tlskey" | grep -v grep)
    if [[ ! -z "$docker_tls_check" ]]; then
        diagnosisResult="Docker API에 TLS 설정이 되어 있음"
        status="양호"
    else
        diagnosisResult="Docker API에 TLS 설정이 되어 있지 않음"
        status="취약"
    fi

    # Check in Docker daemon.json configuration
    if grep -E "tlsverify|tlscacert|tlscert|tlskey" "/etc/docker/daemon.json" > /dev/null; then
        diagnosisResult="Docker API에 TLS 설정이 되어 있음"
        status="양호"
    fi

    # Output result for Docker TLS configuration check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "Docker TLS 설정 확인: $diagnosisResult" >> $TMP1
}

# Run the checks for TLS configuration
check_tls_configuration

# Check Docker TLS settings (if applicable)
check_docker_tls_configuration

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
