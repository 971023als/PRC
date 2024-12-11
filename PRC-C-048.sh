#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-048"
riskLevel="2"
diagnosisItem="cgroup 사용 확인"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-048"
diagnosisItem="cgroup 사용 여부 점검"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'HostConfig.CgroupParent' 값이 'docker' 또는 유사 값으로 설정된 경우
[취약]: 'HostConfig.CgroupParent' 값이 존재하지 않거나 비어있는 경우
EOF

BAR

# Function to check cgroup usage for each container
check_cgroup_usage() {
    local container_id=$1
    local cgroup_parent=""

    # Retrieve the CgroupParent for the container
    cgroup_parent=$(docker inspect --format '{{ .HostConfig.CgroupParent }}' $container_id)

    if [ -z "$cgroup_parent" ]; then
        diagnosisResult="컨테이너 $container_id는 CgroupParent 값이 설정되지 않았습니다. 리소스 제한이 적용되지 않았습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    elif [[ "$cgroup_parent" == "docker"* ]]; then
        diagnosisResult="컨테이너 $container_id는 적절한 cgroup('docker' 또는 유사 값)에 속해 있습니다."
        status="양호"
    else
        diagnosisResult="컨테이너 $container_id는 '$cgroup_parent'에 속해 있으며, 적절한 리소스 제한이 적용되지 않을 수 있습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Retrieve list of all running containers
container_ids=$(docker ps --quiet --all)

for container_id in $container_ids; do
    check_cgroup_usage $container_id
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
