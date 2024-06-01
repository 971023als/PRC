#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-030"
riskLevel="3"
diagnosisItem="가상 디스크 축소 및 삭제 기능 제한 설정"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-030"
diagnosisItem="가상 디스크 축소 및 삭제 기능 제한 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 가상 디스크 축소 및 삭제 기능이 제한된 경우
[취약]: 가상 디스크 축소 및 삭제 기능이 제한되지 않은 경우
EOF

BAR

# Function to check disk shrink and wipe settings on ESXi
check_esxi_disk_settings() {
    local esxi_host=$1
    local vm_id=$2
    local shrink_status="양호"
    local wiper_status="양호"

    shrink_check=$(ssh root@$esxi_host "vim-cmd vmsvc/get.config $vm_id | grep 'isolation.tools.diskShrink.disable'" | wc -l)
    wiper_check=$(ssh root@$esxi_host "vim-cmd vmsvc/get.config $vm_id | grep 'isolation.tools.diskWiper.disable'" | wc -l)

    if [ $shrink_check -eq 0 ]; then
        shrink_status="취약"
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 가상 디스크 축소 기능 제한 설정이 없습니다."
        echo "WARN: $diagnosisResult" >> $TMP1
    fi

    if [ $wiper_check -eq 0 ]; then
        wiper_status="취약"
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 가상 디스크 삭제 기능 제한 설정이 없습니다."
        echo "WARN: $diagnosisResult" >> $TMP1
    fi

    status="양호"
    if [ "$shrink_status" == "취약" ] || [ "$wiper_status" == "취약" ]; then
        status="취약"
    fi

    diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 가상 디스크 축소 및 삭제 기능 제한 설정이 적절합니다."
    if [ "$status" == "취약" ]; then
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 가상 디스크 축소 및 삭제 기능 제한 설정이 적절하지 않습니다."
    fi
    echo "OK: $diagnosisResult" >> $TMP1

    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Replace with actual ESXi hosts and VM IDs
esxi_hosts=("esxi_host1" "esxi_host2")
vm_ids=("vm_id1" "vm_id2")

for esxi_host in "${esxi_hosts[@]}"; do
    for vm_id in "${vm_ids[@]}"; do
        check_esxi_disk_settings $esxi_host $vm_id
    done
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
