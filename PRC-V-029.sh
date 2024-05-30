#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-029"
riskLevel="3"
diagnosisItem="가상머신의 불필요한 장치 제거"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-029"
diagnosisItem="가상머신의 불필요한 장치 제거"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 불필요한 장치가 가상머신에 연결되어 있지 않을 경우
[취약]: 불필요한 장치가 가상머신에 연결되어 있을 경우
EOF

BAR

# Function to check for unnecessary devices on ESXi
check_esxi_unnecessary_devices() {
    local esxi_host=$1
    local vm_id=$2
    local unnecessary_devices=("vim.vm.device.VirtualFloppy" "vim.vm.device.VirtualCdrom" "vim.vm.device.VirtualParallelPort" "vim.vm.device.VirtualSerialPort" "vim.vm.device.VirtualUSBController")
    local device_status="양호"

    for device in "${unnecessary_devices[@]}"; do
        device_count=$(ssh root@$esxi_host "vim-cmd vmsvc/device.getdevices $vm_id" | grep "$device" | wc -l)
        if [ $device_count -gt 0 ]; then
            device_status="취약"
            diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 불필요한 장치 $device가 연결되어 있습니다."
            echo "WARN: $diagnosisResult" >> $TMP1
            break
        fi
    done

    if [ "$device_status" == "양호" ]; then
        diagnosisResult="ESXi 호스트 $esxi_host의 VM ID $vm_id에 불필요한 장치가 연결되어 있지 않습니다."
        echo "OK: $diagnosisResult" >> $TMP1
    fi

    status=$device_status
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Replace with actual ESXi hosts and VM IDs
esxi_hosts=("esxi_host1" "esxi_host2")
vm_ids=("vm_id1" "vm_id2")

for esxi_host in "${esxi_hosts[@]}"; do
    for vm_id in "${vm_ids[@]}"; do
        check_esxi_unnecessary_devices $esxi_host $vm_id
    done
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
