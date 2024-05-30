#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_vib_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-015"
riskLevel="중"
diagnosisItem="이미지 프로필 및 VIB 승인 레벨 설정 미흡"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-015"
diagnosisItem="이미지 프로필 및 VIB 승인 레벨 설정 미흡"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: VIB 승인 레벨이 Partner Supported 이상인 경우
[취약]: VIB 승인 레벨이 Community Supported 인 경우
EOF

BAR

# Function to check ESXi VIB acceptance level
check_esxi() {
    local esxi_host=$1
    local vib_level=$(ssh root@$esxi_host 'esxcli software acceptance get')
    if [[ $vib_level == *"PartnerSupported"* || $vib_level == *"VMwareAccepted"* || $vib_level == *"VMwareCertified"* ]]; then
        diagnosisResult="ESXi 호스트 $esxi_host VIB 승인 레벨이 적절합니다: $vib_level"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host VIB 승인 레벨이 부적절합니다: $vib_level"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter VIB acceptance level for connected ESXi hosts
check_vcenter() {
    local vcenter_host=$1
    local esxi_hosts=$(ssh root@$vcenter_host 'vim-cmd vmsvc/getallvms | grep -oP "(?<=ESXi )[^ ]+"')
    for esxi_host in $esxi_hosts; do
        check_esxi $esxi_host
    done
}

# Check for vCenter
check_vcenter "vcenter_hostname"

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
