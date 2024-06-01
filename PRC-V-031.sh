#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-031"
riskLevel="3"
diagnosisItem="가상머신 콘솔 클립보드 복사&붙여넣기 기능 비활성화"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-031"
diagnosisItem="가상머신 콘솔 클립보드 복사&붙여넣기 기능 비활성화 미설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 가상머신 콘솔 클립보드 복사&붙여넣기 기능이 비활성화된 경우
[취약]: 가상머신 콘솔 클립보드 복사&붙여넣기 기능이 활성화된 경우
EOF

BAR

# Function to check clipboard copy/paste settings on ESXi
check_esxi_clipboard_settings() {
    local esxi_host=$1
    local vm_id=$2
    local copy_status="양호"
    local paste_status="양호"

    copy_check=$(ssh root@$esxi_host "vim-cmd vmsvc/get.config $vm_id | grep 'isolation.tools.copy.disable'" | wc -l)
    paste_check=$(ssh root@$esxi_host "vim-cmd vmsvc/get.config $vm_id | grep 'isolation.tools.paste.disable'" | wc -l)

    if [ $copy_check -eq 0 ]; then
        copy_status="취약"
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 클립보드 복사 기능 비활성화 설정이 없습니다."
        echo "WARN: $diagnosisResult" >> $TMP1
    fi

    if [ $paste_check -eq 0 ]; then
        paste_status="취약"
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 클립보드 붙여넣기 기능 비활성화 설정이 없습니다."
        echo "WARN: $diagnosisResult" >> $TMP1
    fi

    status="양호"
    if [ "$copy_status" == "취약" ] || [ "$paste_status" == "취약" ]; then
        status="취약"
    fi

    diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 클립보드 복사 및 붙여넣기 기능 비활성화 설정이 적절합니다."
    if [ "$status" == "취약" ]; then
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 클립보드 복사 및 붙여넣기 기능 비활성화 설정이 적절하지 않습니다."
    fi
    echo "OK: $diagnosisResult" >> $TMP1

    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Replace with actual ESXi hosts and VM IDs
esxi_hosts=("esxi_host1" "esxi_host2")
vm_ids=("vm_id1" "vm_id2")

for esxi_host in "${esxi_hosts[@]}"; do
    for vm_id in "${vm_ids[@]}"; do
        check_esxi_clipboard_settings $esxi_host $vm_id
    done
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
