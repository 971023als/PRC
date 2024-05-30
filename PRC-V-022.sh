#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_syslog_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-022"
riskLevel="3"
diagnosisItem="원격 로그 서버 이용"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-022"
diagnosisItem="원격 로그 서버 이용"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 원격 로그 서버 또는 스토리지가 연동 설정되어 있을 경우
[취약]: 원격 로그 서버 또는 스토리지가 연동 설정되어 있지 않은 경우
EOF

BAR

# Function to check syslog configuration on ESXi hosts
check_esxi_syslog() {
    local esxi_host=$1
    local syslog_config=$(ssh root@$esxi_host 'esxcli system syslog config get')
    local log_host=$(echo "$syslog_config" | grep -i 'LogHost:' | awk '{print $2}')

    if [ "$log_host" != "None" ] && [ -n "$log_host" ]; then
        diagnosisResult="ESXi 호스트 $esxi_host 원격 로그 서버가 설정되어 있습니다: $log_host"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host 원격 로그 서버가 설정되어 있지 않습니다"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter for syslog configuration
check_vcenter_syslog() {
    local vcenter_host=$1
    local syslog_config=$(ssh root@$vcenter_host 'curl -k -u administrator@vsphere.local:password -X GET "https://localhost:5480/rest/vcenter/settings/v1/configurations/4"')
    local log_host=$(echo "$syslog_config" | grep -i 'Syslog.global.logHost' | awk -F':' '{print $2}' | tr -d '", ')

    if [ "$log_host" != "None" ] && [ -n "$log_host" ]; then
        diagnosisResult="vCenter 서버 $vcenter_host 원격 로그 서버가 설정되어 있습니다: $log_host"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="vCenter 서버 $vcenter_host 원격 로그 서버가 설정되어 있지 않습니다"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Check for vCenter
check_vcenter_syslog "vcenter_hostname"

# Check for each ESXi host
esxi_hosts=("esxi_host1" "esxi_host2" "esxi_host3")
for esxi_host in "${esxi_hosts[@]}"; do
    check_esxi_syslog $esxi_host
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
