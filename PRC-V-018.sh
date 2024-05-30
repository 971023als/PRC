#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_esxi_shell_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-018"
riskLevel="5"
diagnosisItem="ESXi Shell 비활성화"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-018"
diagnosisItem="ESXi Shell 비활성화"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: ESXi Shell(TSM, TSM-SSH) 서비스가 비활성화 되어 있는 경우
[취약]: ESXi Shell(TSM, TSM-SSH) 서비스가 활성화 되어 있는 경우
EOF

BAR

# Function to check ESXi Shell (TSM, TSM-SSH) status
check_esxi() {
    local esxi_host=$1
    local esx_shell_status=$(ssh root@$esxi_host 'localcli network firewall ruleset list | grep -i "ESXiShell\|TSM-SSH" | grep -i "true"')
    
    if [ -z "$esx_shell_status" ]; then
        diagnosisResult="ESXi 호스트 $esxi_host Shell(TSM, TSM-SSH) 서비스가 비활성화 되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host Shell(TSM, TSM-SSH) 서비스가 활성화 되어 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter connected ESXi hosts for Shell status
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
