#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_session_timeout_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-017"
riskLevel="중"
diagnosisItem="관리 홈페이지 세션 타임아웃 설정"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-017"
diagnosisItem="관리 홈페이지 세션 타임아웃 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 세션 타임아웃 값이 900초 이하로 설정된 경우
[취약]: 세션 타임아웃 값이 900초 이하로 설정되지 않은 경우
EOF

BAR

# Function to check ESXi session timeout configuration
check_esxi() {
    local esxi_host=$1
    local session_timeout=$(ssh root@$esxi_host 'vim-cmd hostsvc/advopt/view UserVars.HostClientSessionTimeout | grep "int Value"')
    local timeout_value=$(echo $session_timeout | awk '{print $3}')
    if [ "$timeout_value" -le 900 ]; then
        diagnosisResult="ESXi 호스트 $esxi_host 세션 타임아웃 값이 적절합니다: $timeout_value"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host 세션 타임아웃 값이 부적절합니다: $timeout_value"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter session timeout configuration
check_vcenter() {
    local vcenter_host=$1
    local session_timeout=$(ssh root@$vcenter_host 'grep -i "vpxd.httpClientIdleTimeout" /etc/vmware-vpx/vpxd.cfg')
    local timeout_value=$(echo $session_timeout | sed -n 's/.*<vpxd.httpClientIdleTimeout>\(.*\)<\/vpxd.httpClientIdleTimeout>.*/\1/p')
    if [ "$timeout_value" -le 900 ]; then
        diagnosisResult="vCenter 세션 타임아웃 값이 적절합니다: $timeout_value"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="vCenter 세션 타임아웃 값이 부적절합니다: $timeout_value"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
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
