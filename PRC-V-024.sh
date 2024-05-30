#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_log_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-024"
riskLevel="3"
diagnosisItem="비휘발성 경로 내 로그 파일 저장"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-024"
diagnosisItem="비휘발성 경로 내 로그 파일 저장"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 로그 파일 경로가 존재하며, 해당 경로가 비휘발성 경로에 저장될 경우
[취약]: 로그 파일 경로가 존재하지 않거나, 휘발성 경로(/scratch/, /tmp, /var/tmp, /run, /dev/shm, /dev/pts 등)에 저장되는 경우
EOF

BAR

# Function to check log path on ESXi hosts
check_esxi_log_path() {
    local esxi_host=$1
    local log_dir=$(ssh root@$esxi_host 'esxcli system syslog config get' | grep -i 'LogDir' | awk -F ': ' '{print $2}')

    if [[ "$log_dir" =~ ^(/scratch|/tmp|/var/tmp|/run|/dev/shm|/dev/pts) ]]; then
        diagnosisResult="ESXi 호스트 $esxi_host 로그 파일 경로가 휘발성 경로에 저장됩니다: $log_dir"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host 로그 파일 경로가 비휘발성 경로에 저장됩니다: $log_dir"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter for log path configuration
check_vcenter_log_path() {
    local vcenter_host=$1
    local log_dir=$(ssh root@$vcenter_host 'curl -k -u administrator@vsphere.local:password -X GET "https://localhost:5480/rest/vcenter/settings/v1/configurations/4"' | grep -i 'Syslog.global.LogDir' | awk -F '"' '{print $4}')

    if [[ "$log_dir" =~ ^(/scratch|/tmp|/var/tmp|/run|/dev/shm|/dev/pts) ]]; then
        diagnosisResult="vCenter 서버 $vcenter_host 로그 파일 경로가 휘발성 경로에 저장됩니다: $log_dir"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="vCenter 서버 $vcenter_host 로그 파일 경로가 비휘발성 경로에 저장됩니다: $log_dir"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Check for vCenter
check_vcenter_log_path "vcenter_hostname"

# Check for each ESXi host
esxi_hosts=("esxi_host1" "esxi_host2" "esxi_host3")
for esxi_host in "${esxi_hosts[@]}"; do
    check_esxi_log_path $esxi_host
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
