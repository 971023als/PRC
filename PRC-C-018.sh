#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-018"
riskLevel="4"
diagnosisItem="kubelet의 iptables 동기화 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-018"
diagnosisItem="kubelet의 iptables 동기화 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: "make-iptables-util-chains" 또는 "makeIPTablesUtilChains" 값이 존재하지 않거나, true로 설정된 경우
[취약]: "make-iptables-util-chains" 또는 "makeIPTablesUtilChains" 값이 false로 설정된 경우
EOF

BAR

# Function to check the kubelet iptables synchronization setting
check_kubelet_iptables_sync() {
    # Check the process for 'make-iptables-util-chains' setting
    iptables_sync=$(ps -ef | grep kubelet | grep -v grep | awk '{print $8}')
    
    # Check in various config files for the setting
    if grep -q "make-iptables-util-chains makeIPTablesUtilChains" "/var/lib/kubelet/config.yaml"; then
        iptables_sync_status="true"
    elif grep -q "make-iptables-util-chains makeIPTablesUtilChains" "/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"; then
        iptables_sync_status="true"
    elif grep -q "make-iptables-util-chains makeIPTablesUtilChains" "/lib/systemd/system/kubelet.service"; then
        iptables_sync_status="true"
    else
        iptables_sync_status="false"
    fi

    # Determine result
    if [[ "$iptables_sync_status" == "true" ]]; then
        diagnosisResult="kubelet의 iptables 동기화 설정이 양호"
        status="양호"
    else
        diagnosisResult="kubelet의 iptables 동기화 설정이 취약"
        status="취약"
    fi

    # Output result for iptables sync check
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
    echo "kubelet iptables sync setting: $diagnosisResult" >> $TMP1
}

# Run the check for kubelet iptables sync
check_kubelet_iptables_sync

# Output results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
