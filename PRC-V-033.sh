#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-033"
riskLevel="3"
diagnosisItem="가상머신 콘솔 드래그 앤 드롭 기능 활성화"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-033"
diagnosisItem="가상머신 콘솔 드래그 앤 드롭 기능 비활성화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 가상머신 콘솔 드래그 앤 드롭 기능이 비활성화된 경우
[취약]: 가상머신 콘솔 드래그 앤 드롭 기능이 활성화된 경우
EOF

BAR

# Function to check drag-and-drop settings on ESXi
check_esxi_dnd_settings() {
    local esxi_host=$1
    local vm_id=$2
    local dnd_status="양호"

    # Check if drag-and-drop is disabled
    dnd_check=$(ssh root@$esxi_host "vim-cmd vmsvc/get.config $vm_id | grep 'isolation.tools.dnd.disable'" | wc -l)

    if [ $dnd_check -eq 0 ]; then
        dnd_status="취약"
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 드래그 앤 드롭 기능 비활성화 설정이 없습니다."
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        dnd_status=$(ssh root@$esxi_host "vim-cmd vmsvc/get.config $vm_id | grep 'isolation.tools.dnd.disable' | awk '{print \$2}'")
        
        if [ "$dnd_status" == "false" ]; then
            diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 드래그 앤 드롭 기능이 활성화되어 있습니다."
            dnd_status="취약"
        else
            diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 드래그 앤 드롭 기능이 비활성화되어 있습니다."
            dnd_status="양호"
        fi
    fi

    status="양호"
    if [ "$dnd_status" == "취약" ]; then
        status="취약"
    fi

    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Replace with actual ESXi hosts and VM IDs
esxi_hosts=("esxi_host1" "esxi_host2")
vm_ids=("vm_id1" "vm_id2")

for esxi_host in "${esxi_hosts[@]}"; do
    for vm_id in "${vm_ids[@]}"; do
        check_esxi_dnd_settings $esxi_host $vm_id
    done
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
