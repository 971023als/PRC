#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-034"
riskLevel="3"
diagnosisItem="가상스위치 MAC 주소 변경 정책 활성화"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-034"
diagnosisItem="가상스위치 MAC 주소 변경 정책 비활성화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 가상스위치 MAC 주소 변경 정책이 비활성화된 경우 (거부)
[취약]: 가상스위치 MAC 주소 변경 정책이 활성화된 경우 (허용)
EOF

BAR

# Function to check MAC address change policy on virtual switches
check_esxi_mac_policy() {
    local esxi_host=$1
    local vswitch_name=$2
    local mac_policy_status="양호"

    # Check if MAC address change policy is allowed
    mac_policy_check=$(ssh root@$esxi_host "esxcli network vswitch standard policy security get --vswitch-name=$vswitch_name | grep 'Allow MAC Address Changes' | awk '{print \$3}'")

    if [ "$mac_policy_check" == "true" ]; then
        mac_policy_status="취약"
        diagnosisResult="ESXi 호스트 $esxi_host의 가상스위치 $vswitch_name에서 MAC 주소 변경이 허용되어 있습니다."
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host의 가상스위치 $vswitch_name에서 MAC 주소 변경이 비활성화되어 있습니다."
        mac_policy_status="양호"
    fi

    status="양호"
    if [ "$mac_policy_status" == "취약" ]; then
        status="취약"
    fi

    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Replace with actual ESXi hosts and virtual switch names
esxi_hosts=("esxi_host1" "esxi_host2")
vswitch_names=("vSwitch1" "vSwitch2")

for esxi_host in "${esxi_hosts[@]}"; do
    for vswitch_name in "${vswitch_names[@]}"; do
        check_esxi_mac_policy $esxi_host $vswitch_name
    done
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
