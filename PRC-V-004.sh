#!/bin/bash

OUTPUT_CSV="vmware_security_assessment.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-004"
riskLevel="5"
diagnosisItem="비밀번호 복잡도 설정 미비"
service="VMWare vCenter, VMWare ESXi"
diagnosisResult=""
status=""

BAR

# Write initial values to CSV
echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 비밀번호 관련 정책들이 설정되어 있을 경우
[취약]: 비밀번호 관련 정책들이 설정되어 있지 않은 경우
EOF

BAR

# Function to check vCenter password complexity
check_vcenter() {
    local result=$(ssh root@vcenter 'localcli hardware ipmi bmc get | grep "PasswordPolicy"')
    if [[ $result =~ "10" ]]; then
        diagnosisResult="vCenter 비밀번호 정책이 적절하게 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="vCenter 비밀번호 정책이 적절하게 설정되지 않았습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$category,$code,$riskLevel,$diagnosisItem,vCenter,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check ESXi password complexity
check_esxi() {
    local result=$(ssh root@esxi 'vim-cmd hostsvc/advopt/view Security.PasswordQualityControl')
    if [[ $result =~ "retry=3" ]]; then
        diagnosisResult="ESXi 비밀번호 정책이 적절하게 설정되어 있습니다."
        status="양호"
        echo "OK: $diagnosisResult"
    else
        diagnosisResult="ESXi 비밀번호 정책이 적절하게 설정되지 않았습니다."
        status="취약"
        echo "WARN: $diagnosisResult"
    fi
    echo "$category,$code,$riskLevel,$diagnosisItem,ESXi,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Perform checks
check_vcenter
check_esxi

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
