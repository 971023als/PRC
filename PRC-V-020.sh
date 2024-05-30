#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_esxi_shell_timeout_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-020"
riskLevel="4"
diagnosisItem="ESXi Shell 세션 타임아웃 설정"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-020"
diagnosisItem="ESXi Shell 세션 타임아웃 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 세션 타임아웃 값(ESXiShellInteractiveTimeOut)이 900 이하일 경우
[취약]: 세션 타임아웃 값(ESXiShellInteractiveTimeOut)이 0이거나, 900초과일 경우
EOF

BAR

# Function to check ESXi Shell session timeout configuration
check_esxi() {
    local esxi_host=$1
    local shell_timeout=$(ssh root@$esxi_host 'vim-cmd hostsvc/advopt/view UserVars.ESXiShellInteractiveTimeOut | grep "int Value"')
    local timeout_value=$(echo $shell_timeout | awk '{print $3}')
    
    if [ "$timeout_value" -le 900 ]; then
        diagnosisResult="ESXi 호스트 $esxi_host Shell 세션 타임아웃 값이 적절합니다: $timeout_value"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host Shell 세션 타임아웃 값이 부적절합니다: $timeout_value"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter connected ESXi hosts for Shell session timeout setting
check_vcenter() {
    local vcenter_host=$1
    local esxi_hosts=$(ssh root@$vcenter_host 'vim-cmd vmsvc/getallvms | grep -oP "(?<=ESXi )[^ ]+"')
    for esxi_host in $esxi_hosts; do
        check_esxi $esxi_host
    done
}

# Check for vCenter
check_vcenter "vcenter_hostname"

# Check for each ESXi host
esxi_hosts=("esxi_host1" "esxi_host2" "esxi_host3")
for esxi_host in "${esxi_hosts[@]}"; do
    check_esxi $esxi_host
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
