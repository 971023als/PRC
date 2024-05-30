#!/bin/bash

. function.sh

OUTPUT_CSV="vmware_event_log_check.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-V-023"
riskLevel="3"
diagnosisItem="시스템 주요 이벤트 로그 설정"
service="OS 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-V-023"
diagnosisItem="시스템 주요 이벤트 로그 설정"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 로그 기록 정책이 내부 정책에 부합하게 설정되어 있는 경우
[취약]: 로그 기록 정책이 내부 정책에 부합하게 설정되지 않은 경우
EOF

BAR

# Function to check log level on ESXi hosts
check_esxi_log_level() {
    local esxi_host=$1
    local log_level=$(ssh root@$esxi_host 'vim-cmd hostsvc/advopt/view Config.HostAgent.log.level' | grep -i 'option.value' | awk -F '"' '{print $4}')

    if [ "$log_level" != "info" ] && [ "$log_level" != "debug" ] && [ "$log_level" != "verbose" ]; then
        diagnosisResult="ESXi 호스트 $esxi_host 로그 레벨이 적절하지 않습니다: $log_level"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="ESXi 호스트 $esxi_host 로그 레벨이 적절하게 설정되어 있습니다: $log_level"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Function to check vCenter for log level configuration
check_vcenter_log_level() {
    local vcenter_host=$1
    local log_level=$(ssh root@$vcenter_host 'curl -k -u administrator@vsphere.local:password -X GET "https://localhost:5480/rest/vcenter/settings/v1/configurations/4"' | grep -i 'config.log.level' | awk -F '"' '{print $4}')

    if [ "$log_level" != "info" ] && [ "$log_level" != "debug" ] && [ "$log_level" != "verbose" ]; then
        diagnosisResult="vCenter 서버 $vcenter_host 로그 레벨이 적절하지 않습니다: $log_level"
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    else
        diagnosisResult="vCenter 서버 $vcenter_host 로그 레벨이 적절하게 설정되어 있습니다: $log_level"
        status="양호"
        echo "OK: $diagnosisResult" >> $TMP1
    fi
    echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Check for vCenter
check_vcenter_log_level "vcenter_hostname"

# Check for each ESXi host
esxi_hosts=("esxi_host1" "esxi_host2" "esxi_host3")
for esxi_host in "${esxi_hosts[@]}"; do
    check_esxi_log_level $esxi_host
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
