#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_coredump_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-026"
riskLevel="3"
diagnosisItem="코어덤프 수집 기능 활성화 여부"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-026"
diagnosisItem="코어덤프 수집 기능 활성화 여부"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 코어덤프 수집 기능이 활성화(true) 되어 있는 경우
[취약]: 코어덤프 수집 기능이 비활성화(false) 되어 있는 경우
EOF

BAR

# Function to check Core Dump on ESXi
check_esxi_coredump() {
    local esxi_host=$1
    local coredump_status=$(ssh root@$esxi_host 'esxcli system coredump network get' | grep "Enabled" | awk '{print $3}')

    if [ "$coredump_status" == "true" ]; then
        diagnosisResult="ESXi 호스트 $esxi_host의 코어덤프 수집 기능이 활성화되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host의 코어덤프 수집 기능이 비활성화되어 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Check for ESXi hosts
check_esxi_coredump "esxi_host1"
check_esxi_coredump "esxi_host2"

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
