#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_dcui_timeout_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-021"
riskLevel="4"
diagnosisItem="DCUI 세션 타임아웃 설정"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-021"
diagnosisItem="DCUI 세션 타임아웃 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 세션 타임아웃 값(DcuiTimeOut)이 900 이하일 경우
[취약]: 세션 타임아웃 값(DcuiTimeOut)이 900 초과일 경우
EOF

BAR

# Function to check DCUI session timeout configuration on ESXi hosts
check_esxi_dcui_timeout() {
    local esxi_host=$1
    local dcui_timeout=$(ssh root@$esxi_host 'vim-cmd hostsvc/advopt/view UserVars.DcuiTimeOut | grep "int Value"')
    local timeout_value=$(echo $dcui_timeout | awk '{print $3}')
    
    if [ "$timeout_value" -le 900 ]; then
        diagnosisResult="ESXi 호스트 $esxi_host DCUI 세션 타임아웃 값이 적절합니다: $timeout_value"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host DCUI 세션 타임아웃 값이 부적절합니다: $timeout_value"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter connected ESXi hosts for DCUI session timeout setting
check_vcenter_dcui_timeout() {
    local vcenter_host=$1
    local esxi_hosts=$(ssh root@$vcenter_host 'vim-cmd vmsvc/getallvms | grep -oP "(?<=ESXi )[^ ]+"')
    for esxi_host in $esxi_hosts; do
        check_esxi_dcui_timeout $esxi_host
    done
}

# Check for vCenter
check_vcenter_dcui_timeout "vcenter_hostname"

# Check for each ESXi host
esxi_hosts=("esxi_host1" "esxi_host2" "esxi_host3")
for esxi_host in "${esxi_hosts[@]}"; do
    check_esxi_dcui_timeout $esxi_host
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
