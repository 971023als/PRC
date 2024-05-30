#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-028"
riskLevel="3"
diagnosisItem="가상머신의 장치 연결 제한 설정 미흡"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-028"
diagnosisItem="가상머신의 장치 연결 제한 설정 미흡"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 가상머신의 장치의 무단 연결 제한 설정(isolation.device.connectable.disable)이 활성화(true) 일 경우
[취약]: 가상머신의 장치의 무단 연결 제한 설정(isolation.device.connectable.disable)이 없거나, 비활성화(false) 일 경우
EOF

BAR

# Function to check device connection restriction on ESXi
check_esxi_device_connection_restriction() {
    local esxi_host=$1
    local vm_id=$2
    local device_connection_status=$(ssh root@$esxi_host "vim-cmd vmsvc/device.getdevices $vm_id" | grep 'isolation.device.connectable.disable' | awk '{print $3}')

    if [ "$device_connection_status" == "true" ]; then
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id의 장치 연결 제한 설정이 활성화되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id의 장치 연결 제한 설정이 비활성화되어 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Replace with actual ESXi hosts and VM IDs
esxi_hosts=("esxi_host1" "esxi_host2")
vm_ids=("vm_id1" "vm_id2")

for esxi_host in "${esxi_hosts[@]}"; do
    for vm_id in "${vm_ids[@]}"; do
        check_esxi_device_connection_restriction $esxi_host $vm_id
    done
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
