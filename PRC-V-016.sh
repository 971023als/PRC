#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_ceip_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-016"
riskLevel="중"
diagnosisItem="CEIP 기능 활성화"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-016"
diagnosisItem="CEIP 기능 활성화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: CEIP에 가입되어 있지 않은 경우
[미흡]: CEIP에 가입되어 있을 경우
EOF

BAR

# Function to check ESXi CEIP configuration
check_esxi() {
    local esxi_host=$1
    local ceip_status=$(ssh root@$esxi_host 'vim-cmd hostsvc/advopt/view UserVars.HostClientCEIPOptIn')
    if [[ $ceip_status == *"int Value: 2"* ]]; then
        diagnosisResult="ESXi 호스트 $esxi_host CEIP에 가입되어 있지 않습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host CEIP에 가입되어 있습니다."
        status="미흡"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter CEIP configuration for connected ESXi hosts
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
