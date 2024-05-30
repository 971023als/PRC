#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_api_security_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-025"
riskLevel="3"
diagnosisItem="API 통신에 대한 보안 프로토콜 사용"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-025"
diagnosisItem="API 통신에 대한 보안 프로토콜 사용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: API URL이 HTTPS를 사용하는 경우
[취약]: API URL이 HTTP를 사용하는 경우
EOF

BAR

# Function to check API URL on vCenter
check_vcenter_api_url() {
    local vcenter_host=$1
    local api_url=$(ssh root@$vcenter_host 'grep -i "VirtualCenter.VimApiUrl" /etc/vmware-vpx/vpxd.cfg' | awk -F '[<>]' '{print $3}')

    if [[ "$api_url" =~ ^https:// ]]; then
        diagnosisResult="vCenter 서버 $vcenter_host API URL이 HTTPS를 사용합니다: $api_url"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="vCenter 서버 $vcenter_host API URL이 HTTP를 사용합니다: $api_url"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Check for vCenter
check_vcenter_api_url "vcenter_hostname"

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
