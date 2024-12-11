#!/bin/bash

. function.sh

OUTPUT_CSV="output.csv"

# Set CSV Headers if the file does not exist
if [ ! -f $OUTPUT_CSV ]; then
    echo "category,code,riskLevel,diagnosisItem,service,diagnosisResult,status" > $OUTPUT_CSV
fi

# Initial Values
category="기술적 보안"
code="PRC-C-049"
riskLevel="2"
diagnosisItem="PID cgroup 제한 설정"
service="컨테이너 가상화 시스템"
diagnosisResult=""
status=""

BAR

CODE="PRC-C-049"
diagnosisItem="PID cgroup을 통한 최대 프로세스 개수 제한 여부 점검"

# Write initial values to CSV
echo "$category,$CODE,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV

TMP1=$(basename "$0").log
> $TMP1

BAR

cat << EOF >> $TMP1
[양호]: 'HostConfig.PidsLimit' 값이 적절하게 설정된 경우
[취약]: 'HostConfig.PidsLimit' 값이 0 또는 -1인 경우
EOF

BAR

# Function to check PidsLimit for each container
check_pid_limit() {
    local container_id=$1
    local pid_limit=""

    # Retrieve the PidsLimit for the container
    pid_limit=$(docker inspect --format '{{ .HostConfig.PidsLimit }}' $container_id)

    if [ "$pid_limit" != "0" ] && [ "$pid_limit" != "-1" ]; then
        diagnosisResult="컨테이너 $container_id에 적절한 PidsLimit 값($pid_limit)이 설정되어 있습니다."
        status="양호"
    else
        diagnosisResult="컨테이너 $container_id에 PidsLimit 값이 0 또는 -1로 설정되어 있습니다. 프로세스 제한이 설정되지 않았습니다."
        status="취약"
        echo "WARN: $diagnosisResult" >> $TMP1
    fi

    # Output to CSV
    echo "$category,$code,$riskLevel,$diagnosisItem,$service,$diagnosisResult,$status" >> $OUTPUT_CSV
}

# Retrieve list of all running containers
container_ids=$(docker ps --quiet --all)

for container_id in $container_ids; do
    check_pid_limit $container_id
done

# Display results
cat $TMP1

echo ; echo

cat $OUTPUT_CSV
