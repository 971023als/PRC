#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-017"
riskLevel="4"
diagnosisItem="kubelet 읽기 전용 포트 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-017"
diagnosisItem="kubelet 읽기 전용 포트 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: "read-only-port" 또는 "readOnlyPort" 값이 0으로 설정되어 있는 경우
[취약]: "read-only-port" 및 "readOnlyPort" 값이 존재하지 않거나, 0으로 설정되지 않은 경우
EOF

BAR

# Function to check the kubelet read-only port setting
check_kubelet_read_only_port() {
    # Check the process for 'read-only-port' setting
    read_only_port=$(ps -ef | grep kubelet | grep -v grep | awk '{print $8}')
    
    # Check in various config files for the setting
    if grep -q "read-only-port readOnlyPort" "/var/lib/kubelet/config.yaml"; then
        read_only_port_status="found"
    elif grep -q "read-only-port readOnlyPort" "/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"; then
        read_only_port_status="found"
    elif grep -q "read-only-port readOnlyPort" "/lib/systemd/system/kubelet.service"; then
        read_only_port_status="found"
    else
        read_only_port_status="not found"
    fi

    # Check if the port is not set to 0
    if [[ "$read_only_port_status" == "found" ]] && [[ "$read_only_port" != "0" ]]; then
        diagnosisResult="kubelet의 읽기 전용 포트가 취약"
        status="취약"
    else
        diagnosisResult="kubelet의 읽기 전용 포트가 양호"
        status="양호"
    fi

    # Output result for read-only port check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "kubelet read-only port setting: $diagnosisResult" >> $TMP1
}

# Run the check for kubelet read-only port
check_kubelet_read_only_port

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
